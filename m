From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Wed, 17 Oct 2007 19:08:44 +1000
Message-ID: <1192612124.11899.165.camel@pasglop>
References: <20071015125301.GC3015@ff.dom.local>
	 <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl>
	 <20071016062108.GB1000@ff.dom.local>
	 <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl>
	 <20071017085809.GA1658@ff.dom.local>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34470 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932221AbXJQJJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 05:09:06 -0400
In-Reply-To: <20071017085809.GA1658@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Btw., since, because of this patch, I've had a one more look at phy.c
> and there are a few more doubts, so this time I'll try to bother you
> for real:

 .../...

While there... is somebody interested in making the whole PHY lib
operate a task level and use mutexes instead of spinlock ? I need that
for drivers like EMAC (who use their own PHY layer for now), and I might
even give a go at adapting phylib myself, but I'd like to take the
temperature about it first.

Basically, there is nothing in phylib that is performance critical or
such that requires it to run at irq time and/or use locks. On the other
hand, it complicates things in various areas. The most obvious one being
that it prevents the network driver mii access callbacks from sleeping
which can be annoying as MDIO can be slow, and some drivers have fancy
muxes in there that are better off mutexed than spinlocked.

Ben.
 

