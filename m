From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25] Use kzalloc
Date: Sun, 9 Jul 2006 02:52:00 +0100
Message-ID: <20060709015200.GA6221@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:43237 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S932427AbWGIKpu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 06:45:50 -0400
Received: from localhost.localdomain ([127.0.0.1]:9873 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133749AbWGIKps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 11:45:48 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace kzalloc instead of kmalloc + memset.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/ax25/af_ax25.c     |    3 +--
 net/ax25/ax25_dev.c    |    4 +---
 net/netrom/af_netrom.c |    4 +---
 net/rose/af_rose.c     |    3 +--
 4 files changed, 4 insertions(+), 10 deletions(-)

Index: linux-net/net/ax25/ax25_dev.c
===================================================================
--- linux-net.orig/net/ax25/ax25_dev.c	2006-07-09 02:48:00.000000000 +0100
+++ linux-net/net/ax25/ax25_dev.c	2006-07-09 02:50:35.000000000 +0100
@@ -55,15 +55,13 @@ void ax25_dev_device_up(struct net_devic
 {
 	ax25_dev *ax25_dev;
 
-	if ((ax25_dev = kmalloc(sizeof(*ax25_dev), GFP_ATOMIC)) == NULL) {
+	if ((ax25_dev = kzalloc(sizeof(*ax25_dev), GFP_ATOMIC)) == NULL) {
 		printk(KERN_ERR "AX.25: ax25_dev_device_up - out of memory\n");
 		return;
 	}
 
 	ax25_unregister_sysctl();
 
-	memset(ax25_dev, 0x00, sizeof(*ax25_dev));
-
 	dev->ax25_ptr     = ax25_dev;
 	ax25_dev->dev     = dev;
 	dev_hold(dev);
Index: linux-net/net/ax25/af_ax25.c
===================================================================
--- linux-net.orig/net/ax25/af_ax25.c	2006-07-09 02:48:01.000000000 +0100
+++ linux-net/net/ax25/af_ax25.c	2006-07-09 02:50:35.000000000 +0100
@@ -486,10 +486,9 @@ ax25_cb *ax25_create_cb(void)
 {
 	ax25_cb *ax25;
 
-	if ((ax25 = kmalloc(sizeof(*ax25), GFP_ATOMIC)) == NULL)
+	if ((ax25 = kzalloc(sizeof(*ax25), GFP_ATOMIC)) == NULL)
 		return NULL;
 
-	memset(ax25, 0x00, sizeof(*ax25));
 	atomic_set(&ax25->refcount, 1);
 
 	skb_queue_head_init(&ax25->write_queue);
Index: linux-net/net/netrom/af_netrom.c
===================================================================
--- linux-net.orig/net/netrom/af_netrom.c	2006-07-09 02:48:01.000000000 +0100
+++ linux-net/net/netrom/af_netrom.c	2006-07-09 02:50:35.000000000 +0100
@@ -1382,14 +1382,12 @@ static int __init nr_proto_init(void)
 		return -1;
 	}
 
-	dev_nr = kmalloc(nr_ndevs * sizeof(struct net_device *), GFP_KERNEL);
+	dev_nr = kzalloc(nr_ndevs * sizeof(struct net_device *), GFP_KERNEL);
 	if (dev_nr == NULL) {
 		printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device array\n");
 		return -1;
 	}
 
-	memset(dev_nr, 0x00, nr_ndevs * sizeof(struct net_device *));
-
 	for (i = 0; i < nr_ndevs; i++) {
 		char name[IFNAMSIZ];
 		struct net_device *dev;
Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c	2006-07-09 02:48:01.000000000 +0100
+++ linux-net/net/rose/af_rose.c	2006-07-09 02:50:35.000000000 +0100
@@ -1490,14 +1490,13 @@ static int __init rose_proto_init(void)
 
 	rose_callsign = null_ax25_address;
 
-	dev_rose = kmalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
+	dev_rose = kzalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
 	if (dev_rose == NULL) {
 		printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate device structure\n");
 		rc = -ENOMEM;
 		goto out_proto_unregister;
 	}
 
-	memset(dev_rose, 0x00, rose_ndevs * sizeof(struct net_device*));
 	for (i = 0; i < rose_ndevs; i++) {
 		struct net_device *dev;
 		char name[IFNAMSIZ];
