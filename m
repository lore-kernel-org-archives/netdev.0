From: Michael Renzmann <netdev@nospam.otaku42.de>
Subject: Re: [PATCH 2.4.31] e1000: unlock tx_lock before return
Date: Tue, 14 Jun 2005 08:51:58 +0200
Message-ID: <42AE7E8E.4030909@otaku42.de>
References: <42ADE90A.8080804@otaku42.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050804000009050602030509"
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261270AbVFNGw0@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <42ADE90A.8080804@otaku42.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050804000009050602030509
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi all.

Sorry for replying to my own post. I rediffed the patch to make it a -p1
patch as described by DaveM in another (netdev) thread. Also CC'd lkml.

lkml'ers, please CC replies to me, since I'm not subscribed.

Michael Renzmann wrote:
> It may happen that the e1000 driver returns from e1000_xmit_frame()
> while still holding the tx_lock spinlock. This is at least true for the
> version that comes with kernel 2.4.31. The problem doesn't exist in
> 2.6.11.12.
> 
> The attached patch applies to vanilla 2.4.31. I couldn't test the patch
> myself (no e1000 available), but it's a trivial patch and thus it's
> expected to work without problems.
> 
> Signed-off-by: Michael Renzmann <mrenzmann@otaku42.de>

--------------050804000009050602030509
Content-Type: text/x-patch;
 name="e1000-2.4.31-unlock_before_return.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000-2.4.31-unlock_before_return.patch"

--- a/drivers/net/e1000/e1000_main.c	2005-04-04 03:42:19.000000000 +0200
+++ b/drivers/net/e1000/e1000_main.c	2005-06-13 21:39:58.000000000 +0200
@@ -1955,8 +1955,8 @@
 		if(unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
-			return 1;
 			spin_unlock_irqrestore(&adapter->tx_lock, flags);
+			return 1;
 		}
 	}
 

--------------050804000009050602030509--
