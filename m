From: David Miller <davem@davemloft.net>
Subject: Re: Kernel problem
Date: Sun, 01 Mar 2009 00:12:28 -0800 (PST)
Message-ID: <20090301.001228.74103701.davem@davemloft.net>
References: <20090227091216.GB4156@ff.dom.local>
	<20090227.011615.104197338.davem@davemloft.net>
	<20090301073801.GA8975@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, ash@sevsky.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750887AbZCAIMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 03:12:47 -0500
In-Reply-To: <20090301073801.GA8975@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 1 Mar 2009 15:38:01 +0800

> netpoll: Add drop checks to all entry points
> 
> The netpoll entry checks are required to ensure that we don't
> receive normal packets when invoked via netpoll.  Unfortunately
> it only ever worked for the netif_receive_skb/netif_rx entry
> points.  The VLAN (and subsequently GRO) entry point didn't
> have the check and therefore can trigger all sorts of weird
> problems.
> 
> This patch adds the netpoll check to all entry points.
> 
> I'm still uneasy with receiving at all under netpoll (which
> apparently is only used by the out-of-tree kdump code).  The
> reason is it is perfectly legal to receive all data including
> headers into highmem if netpoll is off, but if you try to do
> that with netpoll on and someone gets a printk in an IRQ handler                                             
> you're going to get a nice BUG_ON.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I don't blame you for being skitting about skb_bond_should_drop()
:-)

Applied, thanks Herbert!
