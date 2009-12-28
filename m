From: Dan Carpenter <error27@gmail.com>
Subject: [patch] hamradio: avoid null deref v3
Date: Mon, 28 Dec 2009 18:54:55 +0200
Message-ID: <20091228165455.GA17645@bicker>
References: <20091223132550.GD17923@bicker> <4B3257C2.2050500@gmail.com> <20091226123812.GB6075@bicker> <20091226.201729.15225529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752303AbZL1Qza@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091226.201729.15225529.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should address the problems in version 1 (lazy) and version 2 (ugly).

Bump the stats on orig_dev not on the newly assigned NULL dev variable.

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/drivers/net/hamradio/bpqether.c	2009-12-22 23:58:56.000000000 +0200
+++ devel/drivers/net/hamradio/bpqether.c	2009-12-28 00:12:48.000000000 +0200
@@ -248,6 +248,7 @@ static netdev_tx_t bpq_xmit(struct sk_bu
 {
 	unsigned char *ptr;
 	struct bpqdev *bpq;
+	struct net_device *orig_dev;
 	int size;
 
 	/*
@@ -282,8 +283,9 @@ static netdev_tx_t bpq_xmit(struct sk_bu
 
 	bpq = netdev_priv(dev);
 
+	orig_dev = dev;
 	if ((dev = bpq_get_ether_dev(dev)) == NULL) {
-		dev->stats.tx_dropped++;
+		orig_dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
