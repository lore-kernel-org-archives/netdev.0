From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Sat, 1 Nov 2014 18:33:00 +0100
Message-ID: <20141101183300.0c04125d@free-electrons.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:47108 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752950AbaKARdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 13:33:04 -0400
In-Reply-To: <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric Dumazet,

On Sat, 01 Nov 2014 10:26:06 -0700, Eric Dumazet wrote:
> On Sat, 2014-11-01 at 12:30 -0300, Ezequiel Garcia wrote:
> > Several users ([1], [2]) have been reporting data corruption with TSO on
> > Kirkwood platforms (i.e. using the mv643xx_eth driver).
> > 
> > Until we manage to find what's causing this, this simple patch will make
> > the TSO path disabled by default. This patch should be queued for stable,
> > fixing the TSO feature introduced in v3.16.
> > 
> > The corruption itself is very easy to reproduce: checking md5sum on a mounted
> > NFS directory gives a different result each time. Same tests using the mvneta
> > driver (Armada 370/38x/XP SoC) pass with no issues.
> > 
> > Frankly, I'm a bit puzzled about this, and so any ideas or debugging hints
> > are well received.
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

As far as I know, ARMv5 does not do out-of-order execution, and so on
ARMv5, mb() == rmb() == wmb() == barrier(). But might be a missing
compiler barrier, indeed, as that's not specific to the architecture.

Thanks for the hint!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
