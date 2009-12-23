From: Dan Carpenter <error27@gmail.com>
Subject: [patch] hamradio: avoid null deref
Date: Wed, 23 Dec 2009 15:25:50 +0200
Message-ID: <20091223132550.GD17923@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755930AbZLWN0S@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If dev == NULL we shouldn't dereference it.

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/drivers/net/hamradio/bpqether.c	2009-12-22 23:58:56.000000000 +0200
+++ devel/drivers/net/hamradio/bpqether.c	2009-12-22 23:59:46.000000000 +0200
@@ -283,7 +283,6 @@ static netdev_tx_t bpq_xmit(struct sk_bu
 	bpq = netdev_priv(dev);
 
 	if ((dev = bpq_get_ether_dev(dev)) == NULL) {
-		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
