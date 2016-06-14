From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 1/3] ipv4: make flow functions more grepable by
 removing flowi4_init_output
Date: Tue, 14 Jun 2016 10:59:33 +0200
Message-ID: <ec6bad87-8d1a-bc6d-6d51-9975012dc44e@stressinduktion.org>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
 <1465850858-8559-2-git-send-email-hannes@stressinduktion.org>
 <alpine.LFD.2.11.1606140856010.2467@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41400 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751702AbcFNI7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 04:59:36 -0400
In-Reply-To: <alpine.LFD.2.11.1606140856010.2467@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.06.2016 08:02, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 13 Jun 2016, Hannes Frederic Sowa wrote:
> 
>> -	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
>> -			   protocol, flow_flags, dst, src, dport, sport);
>> +	fl4->flowi4_oif = oif;
>> +	fl4->flowi4_iif = LOOPBACK_IFINDEX;
>> +	fl4->flowi4_mark = sk->sk_mark;
>> +	fl4->flowi4_tos = tos;
>> +	fl4->flowi4_scope = RT_SCOPE_UNIVERSE;
>> +	fl4->flowi4_proto = protocol;
>> +	fl4->flowi4_flags = flow_flags;
>> +	fl4->flowi4_secid = 0;
>> +	fl4->flowi4_tun_key.tun_id = 0;
>> +	fl4->daddr = dst;
>> +	fl4->saddr = src;
>> +	fl4->fl4_dport = dport;
>> +	fl4->fl4_sport = sport;
> 
> 	The way you initialize the fields adds new risks
> when new field is added, it is difficult to track all such
> places. If they are missed, the lookup will use random
> value for the new field. I'm not sure what will compile,
> may be something likes this?:
> 
> 	*fl4 = (struct flowi4) {
> 		.flowi4_oif = oif,
> 		...
> 	};

Yes, this is probably the better way to go, I adapted my patch accordingly.

Thanks,
