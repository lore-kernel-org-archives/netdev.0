From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [PATCH 0/5] netfilter updates for net-next (upcoming
	3.5), batch 2
Date: Thu, 10 May 2012 06:00:00 +0200 (CEST)
Message-ID: <p9l17hj.bb22250845107efca259c380861808ee@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:54884 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704Ab2EJEAE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 00:00:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
>From: pablo@netfilter.org
>Date: Wed,  9 May 2012 13:33:03 +0200
>
>> This is a second batch of netfilter updates for net-next, they contain:
>> 
>> * The new HMARK target from Hans Schillstrom. It took lots of spins
>>   to get this into shape. This target provides a hash-based packet / flow
>>   pre-classifier for iptables that can be used to distribute packets
>>   / flows between uplinks and backend servers. It provides to modes, one
>>   that relies on conntrack, and one that is stateless per-packet.
>> 
>> * Byte-based cost calculation for the hashlimit match, to detect when
>>   a host consumes more bandwidth than expected. This patch from Florian
>>   Westphal.
>> 
>> You can pull these changes from:
>> 
>> git://1984.lsi.us.es/net-next
>
>Pulled.
>
>Two suggested improvements:
>
>1) The HMARK hash is quite expensive, because it uses a modulus.
>
>   Consider adjusting it to use the usual trick:
>
>	((u64)(HASH_VAL * HASH_SIZE)) >> 32
>
>   so that this can be a multiply instead of a modulus.

That's true 

>2) XT_HASHLIMIT_MAX is cumbersome.
>
>   The canonical way to validate if the set bits are in	a
>   valid range is to have a "_ALL" macro, and test:
>
>	if (val & ~XT_HASHLIMIT_ALL)
>		goto err;
>
>   or similar.
>

Thanks David  
I'll fix it

Regards 
Hans Schillstrom
