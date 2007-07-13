From: Philippe De Muyter <phdm@macqel.be>
Subject: Re: [PATCH] 7990 : Various fixes and cleanups
Date: Fri, 13 Jul 2007 12:44:19 +0200
Message-ID: <20070713104419.GA32178@ingate.macqel.be>
References: <20070706095828.GA12270@muff.macqel.be> <4693B615.6010605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.macqel.be ([194.78.208.39]:17161 "EHLO mail.macqel.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751960AbXGMKoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 06:44:21 -0400
Content-Disposition: inline
In-Reply-To: <4693B615.6010605@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 10, 2007 at 12:38:45PM -0400, Jeff Garzik wrote:
> Philippe De Muyter wrote:
> >This patch
> >- avoids 7990 blocking when no tx buffer is available,
> [...]
> >diff -r 6c0a10cc415a drivers/net/7990.c
> >--- a/drivers/net/7990.c	Thu Jul  5 16:10:16 2007 -0700
> >+++ b/drivers/net/7990.c	Fri Jul  6 11:27:20 2007 +0200
> [...]
> >@@ -541,9 +546,6 @@ int lance_start_xmit (struct sk_buff *sk
> >         static int outs;
> > 	unsigned long flags;
> > 
> >-        if (!TX_BUFFS_AVAIL)
> >-                return -1;
> >-
> > 	netif_stop_queue (dev);
> > 
> >         skblen = skb->len;
> 
> 
> NAK
> 
> It "avoids" by removing an overrun check in hard_start_xmit that should 
> not be removed.

Yup, sorry.

The real fact is still that this prevents/fixes lance/driver blocking on my
board, while the tx_timeout mechanism does not succeed at that, and that
on my board the driver is blocked when we return -1 on !TX_BUFFS_AVAIL.

I'll investigate why.

Philippe

PS : did you apply the rest of the patch ?

-- 
Philippe De Muyter  phdm at macqel dot be  Tel +32 27029044
Macq Electronique SA  rue de l'Aeronef 2  B-1140 Bruxelles  Fax +32 27029077
