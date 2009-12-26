From: Dan Carpenter <error27@gmail.com>
Subject: [patch] hamradio: avoid null deref v2
Date: Sat, 26 Dec 2009 14:38:12 +0200
Message-ID: <20091226123812.GB6075@bicker>
References: <20091223132550.GD17923@bicker> <4B3257C2.2050500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753073AbZLZMiy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B3257C2.2050500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bump the stats on the original dev not on the newly assigned NULL version of
dev.

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/drivers/net/hamradio/bpqether.c	2009-12-22 23:58:56.000000000 +0200
+++ devel/drivers/net/hamradio/bpqether.c	2009-12-25 19:49:05.000000000 +0200
@@ -282,11 +282,12 @@ static netdev_tx_t bpq_xmit(struct sk_bu
 
 	bpq = netdev_priv(dev);
 
-	if ((dev = bpq_get_ether_dev(dev)) == NULL) {
+	if (!bpq->ethdev) {
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
+	dev = bpq_get_ether_dev(dev);
 
 	skb->protocol = ax25_type_trans(skb, dev);
 	skb_reset_network_header(skb);
