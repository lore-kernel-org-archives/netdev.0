From: Patrick McHardy <kaber@trash.net>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Tue, 14 Oct 2008 23:54:37 +0200
Message-ID: <48F5151D.4060304@trash.net>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>	<E1KpkSl-00087W-GB@gondolin.me.apana.org.au> <20081014104621.3c2ce4d3@extreme> <48F514AD.3010109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Krzysztof Oledzki <ole@ans.pl>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47604 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbYJNVyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 17:54:40 -0400
In-Reply-To: <48F514AD.3010109@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Stephen Hemminger wrote:
>> There is no easy solution, I'll will have to go back rewrite this
>> code, and will document the result. I expect the result will displease
>> someone, but given the original code that is just going to happen.
>>
>> Busted cases:
>>                            correct           incorrect
>> Original code: 127.2   =>  127.0.0.2         127.2.0.0
>> inet_pton:     10.0    =>  10.0.0.0          fails invalid
>> inet_aton:     10      =>  10.0.0.0          0.0.0.10
>>
>> The problem was Alexey (or Jamal) invented their own abbreviation format
>> and did not follow unix standard conventions.
> 
> We fixed the same problem in iptables a few years ago, maybe you could
> reuse some of that code. Some quick testing shows that it parses all
> addresses according to your table:
> 
> # iptables -I OUTPUT -d 127.2
> # iptables -I OUTPUT -d 10.0
> # iptables -I OUTPUT -d 10
> # iptables -vxnL OUTPUT
> Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
>     pkts      bytes target     prot opt in     out     source      
> destination
>        0        0            all  --  *      *       0.0.0.0/0    10.0.0.0
>        0        0            all  --  *      *       0.0.0.0/0    10.0.0.0
>        0        0            all  --  *      *       0.0.0.0/0    127.2.0.0

OK, the last one is wrong. I thought we fixed that :)
