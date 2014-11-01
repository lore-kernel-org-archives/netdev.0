From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Sat, 01 Nov 2014 13:42:15 -0400 (EDT)
Message-ID: <20141101.134215.1777123022766405287.davem@davemloft.net>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ezequiel.garcia@free-electrons.com, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, tawfik@marvell.com,
	alior@marvell.com, nadavh@marvell.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755267AbaKARmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 13:42:17 -0400
In-Reply-To: <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 01 Nov 2014 10:26:06 -0700

> On Sat, 2014-11-01 at 12:30 -0300, Ezequiel Garcia wrote:
>> Several users ([1], [2]) have been reporting data corruption with TSO on
>> Kirkwood platforms (i.e. using the mv643xx_eth driver).
>> 
>> Until we manage to find what's causing this, this simple patch will make
>> the TSO path disabled by default. This patch should be queued for stable,
>> fixing the TSO feature introduced in v3.16.
>> 
>> The corruption itself is very easy to reproduce: checking md5sum on a mounted
>> NFS directory gives a different result each time. Same tests using the mvneta
>> driver (Armada 370/38x/XP SoC) pass with no issues.
>> 
>> Frankly, I'm a bit puzzled about this, and so any ideas or debugging hints
>> are well received.
> 
> lack of barriers maybe ?
> 
> It seems you might need to populate all TX descriptors but delay the
> first, like doing the populate in descending order.
> 
> If you take a look at txq_submit_skb(), you'll see the final
> desc->cmd_sts = cmd_sts (line 959) is done _after_ frags were cooked by
> txq_submit_frag_skb()
> 
> You should kick the nick only when all TX descriptors are ready and
> committed to memory.

Yes, please look into whether doing something like this fixes the
problem.
