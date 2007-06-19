From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 tx problem (1s pause with ping)
Date: Wed, 20 Jun 2007 01:06:41 +0200
Message-ID: <20070619230641.GD14681@electric-eye.fr.zoreil.com>
References: <20070613004154.GA4187@kvack.org> <20070613211859.GA22521@electric-eye.fr.zoreil.com> <46715FBA.3070302@iinet.net.au> <20070614220050.GB23266@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Benjamin LaHaise <bcrl@kvack.org>
To: David Gundersen <gundy@iinet.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56984 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754650AbXFSXJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 19:09:25 -0400
Content-Disposition: inline
In-Reply-To: <20070614220050.GB23266@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> A pesky fever apart, I should be able to come with a patch before
> the week end.

(oops, late again)

You can try the hack below as a temporary fix.

It makes things way better on top of 2.6.22-rc5 + current r8169 patchkit at
http://www.fr.zoreil.com/people/francois/misc/20070619-2.6.22-rc5-r8169-test.patch

It applies against 2.6.22-rc5 too.

I should come with something else soon.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 8f3e0da..8c0851f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2682,6 +2688,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
+		if (tp->dirty_tx != tp->cur_rx)
+			RTL_W8(TxPoll, NPQ);
 	}
 }
 

