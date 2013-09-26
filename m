From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v4 1/3] flow_dissector: factor out the ports
 extraction in skb_flow_get_ports
Date: Thu, 26 Sep 2013 18:35:33 +0200
Message-ID: <52446255.6040108@redhat.com>
References: <1380212024-3417-1-git-send-email-nikolay@redhat.com>  <1380212024-3417-2-git-send-email-nikolay@redhat.com> <1380213202.3165.195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com, vfalico@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581Ab3IZQkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 12:40:17 -0400
In-Reply-To: <1380213202.3165.195.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2013 06:33 PM, Eric Dumazet wrote:
> On Thu, 2013-09-26 at 18:13 +0200, Nikolay Aleksandrov wrote:
> 
>>  	flow->ip_proto = ip_proto;
>> -	poff = proto_ports_offset(ip_proto);
>> -	if (poff >= 0) {
>> -		__be32 *ports, _ports;
>> -
>> -		nhoff += poff;
>> -		ports = skb_header_pointer(skb, nhoff, sizeof(_ports), &_ports);
>> -		if (ports)
>> -			flow->ports = *ports;
>> -	}
>> -
>> +	flow->ports = skb_flow_get_ports(skb, nhoff, ip_proto);
>>  	flow->thoff = (u16) nhoff;
>>  
>>  	return true;
> 
> 
> 
> The best way is to ask David to apply my fix in net tree, then your
> patch will be on top of it.
> 
> Mixing a fix and a factoring seems not right.
> 
> 
Ah, okay, sorry about that, I'm hurrying again :-)
Dave would you apply Eric's fix in the net-next tree ?
I'll then re-base on it.

Thanks,
 Nik
