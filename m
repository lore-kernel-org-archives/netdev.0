From: David Miller <davem@davemloft.net>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Fri, 02 Jan 2015 15:36:55 -0500 (EST)
Message-ID: <20150102.153655.1853692198479011402.davem@davemloft.net>
References: <20141231133923.GA30248@gondor.apana.org.au>
	<20141231134217.GB30248@gondor.apana.org.au>
	<1420223040.32621.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, thomas.jarosch@intra2net.com,
	netdev@vger.kernel.org, edumazet@google.com,
	steffen.klassert@secunet.com, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbbABUhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:37:00 -0500
In-Reply-To: <1420223040.32621.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Jan 2015 10:24:00 -0800

> On Thu, 2015-01-01 at 00:42 +1100, Herbert Xu wrote:
>> Firstly not many people test non-TSO code paths anymore so bugs
>> are likely to persist for a long time there.  Perhaps it's time
>> to remove the non-TSO code path altogether? The GSO code path
>> should provide enough speed-up in terms of boosting the effective
>> MTU to offset the cost of copying.
> 
>> Secondly why are we dealing with hardware TSO segment limits
>> by limiting the size of the TSO packet in the TCP stack? Surely
>> in this case GSO is free since there won't be any copying?
> 
> It might depends on the device capabilities.
> 
> Non TSO/GSO path is known to be better for devices unable to perform TX
> checksumming, as we compute the checksum at the time we copy data from
> user to kernel (csum_and_copy_from_user() from tcp_sendmsg())).

Non-SG capable devices suffer in this scenerio as well.
