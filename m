From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] tipc: fix build issue when building without IPv6
Date: Thu, 19 Mar 2015 16:16:41 -0300
Message-ID: <550B2099.50109@gmail.com>
References: <1426778023-27486-1-git-send-email-marcelo.leitner@gmail.com> <20150319.150433.850095478975909930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, jon.maloy@ericsson.com,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, erik.hugne@ericsson.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34950 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbCSTQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 15:16:47 -0400
Received: by qgez64 with SMTP id z64so74202564qge.2
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 12:16:46 -0700 (PDT)
In-Reply-To: <20150319.150433.850095478975909930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19-03-2015 16:04, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Thu, 19 Mar 2015 12:13:43 -0300
>
>> @@ -387,6 +391,11 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
>>   	tuncfg.encap_destroy = NULL;
>>   	setup_udp_tunnel_sock(net, ub->ubsock, &tuncfg);
>>
>> +	/* At this point, IPv6 module should have been loaded in
>> +	 * udp_sock_create/sock_create_kern().
>> +	 */
>> +	BUG_ON(!ipv6_stub);
>> +
>
> If IPV6=n this will be NULL no matter what.
>
> And if the module load gets an error, this will be NULL as well.
>

Oh indeed, and it (whatever check) should have been placed in a 
ipv6-only path, like vxlan used to do.

Will fix, thanks.

   Marcelo
