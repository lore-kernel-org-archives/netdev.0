From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: drivers/net/cris/eth_v10.c:1715:2: error: too many arguments
 to function 'e100rxtx_interrupt'
Date: Wed, 3 Oct 2012 12:46:52 +0200
Message-ID: <20121003104652.GK1390@axis.com>
References: <20120928130608.GA5158@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anubis.se.axis.com ([195.60.68.12]:60429 "EHLO
	anubis.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750Ab2JCKzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 06:55:11 -0400
Content-Disposition: inline
In-Reply-To: <20120928130608.GA5158@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 28, 2012 at 03:06:08PM +0200, Fengguang Wu wrote:
> Hi Jesper,

Hi!

> FYI, a rather old build bug that's introduced by
> 
> bafef0a cris build fixes: update eth_v10.c ethernet driver
> 
> All error/warnings:
> 
> drivers/net/cris/eth_v10.c: In function 'e100_netpoll':
> drivers/net/cris/eth_v10.c:1715:2: error: too many arguments to function 'e100rxtx_interrupt'
> drivers/net/cris/eth_v10.c:1131:1: note: declared here

Yep, I can't figure out why the followup patches never reached mainline,
but we have fixes for exactly that in our in-house tree.
I'll push some move patches after this merge window.

> vim +1715 drivers/net/cris/eth_v10.c
> 
> ^1da177e (Linus Torvalds 2005-04-16  1710) 
> bafef0ae (Jesper Nilsson 2007-11-14  1711) #ifdef CONFIG_NET_POLL_CONTROLLER
> bafef0ae (Jesper Nilsson 2007-11-14  1712) static void
> bafef0ae (Jesper Nilsson 2007-11-14  1713) e100_netpoll(struct net_device* netdev)
> bafef0ae (Jesper Nilsson 2007-11-14  1714) {
> bafef0ae (Jesper Nilsson 2007-11-14 @1715) 	e100rxtx_interrupt(NETWORK_DMA_TX_IRQ_NBR, netdev, NULL);
> bafef0ae (Jesper Nilsson 2007-11-14  1716) }
> bafef0ae (Jesper Nilsson 2007-11-14  1717) #endif
> bafef0ae (Jesper Nilsson 2007-11-14  1718) 
> ^1da177e (Linus Torvalds 2005-04-16  1719) static int
> ^1da177e (Linus Torvalds 2005-04-16  1720) etrax_init_module(void)
> ^1da177e (Linus Torvalds 2005-04-16  1721) {
> ^1da177e (Linus Torvalds 2005-04-16  1722) 	return etrax_ethernet_init();
> ^1da177e (Linus Torvalds 2005-04-16  1723) }

Thanks!

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
