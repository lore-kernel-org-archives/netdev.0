From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.28] myri10ge: use DCA if DCA is compiled as a module
Date: Sat, 13 Sep 2008 22:30:06 +0200
Message-ID: <48CC22CE.8050608@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1945 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752239AbYIMUb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 16:31:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DCA in myri10ge when CONFIG_DCA_MODULE is set as well.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

Index: linux-2.6.git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.git.orig/drivers/net/myri10ge/myri10ge.c	2008-09-13 22:22:12.000000000 +0200
+++ linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2008-09-13 22:23:43.000000000 +0200
@@ -189,7 +189,7 @@
 	dma_addr_t fw_stats_bus;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	int cached_dca_tag;
 	int cpu;
 	__be32 __iomem *dca_tag;
@@ -221,7 +221,7 @@
 	int msi_enabled;
 	int msix_enabled;
 	struct msix_entry *msix_vectors;
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	int dca_enabled;
 #endif
 	u32 link_state;
@@ -905,7 +905,7 @@
 	struct myri10ge_slice_state *ss;
 	int i, status;
 	size_t bytes;
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	unsigned long dca_tag_off;
 #endif
 
@@ -1015,7 +1015,7 @@
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_DCA_OFFSET, &cmd, 0);
 	dca_tag_off = cmd.data0;
 	for (i = 0; i < mgp->num_slices; i++) {
@@ -1054,7 +1054,7 @@
 	return status;
 }
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 static void
 myri10ge_write_dca(struct myri10ge_slice_state *ss, int cpu, int tag)
 {
@@ -1508,7 +1508,7 @@
 	struct net_device *netdev = ss->mgp->dev;
 	int work_done;
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	if (ss->mgp->dca_enabled)
 		myri10ge_update_dca(ss);
 #endif
@@ -1739,7 +1739,7 @@
 	"tx_boundary", "WC", "irq", "MSI", "MSIX",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "watchdog_resets",
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	"dca_capable_firmware", "dca_device_present",
 #endif
 	"link_changes", "link_up", "dropped_link_overflow",
@@ -1818,7 +1818,7 @@
 	data[i++] = (unsigned int)mgp->read_write_dma;
 	data[i++] = (unsigned int)mgp->serial_number;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	data[i++] = (unsigned int)(mgp->ss[0].dca_tag != NULL);
 	data[i++] = (unsigned int)(mgp->dca_enabled);
 #endif
@@ -4040,7 +4040,7 @@
 		dev_err(&pdev->dev, "failed reset\n");
 		goto abort_with_slices;
 	}
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	myri10ge_setup_dca(mgp);
 #endif
 	pci_set_drvdata(pdev, mgp);
@@ -4144,7 +4144,7 @@
 	netdev = mgp->dev;
 	unregister_netdev(netdev);
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	myri10ge_teardown_dca(mgp);
 #endif
 	myri10ge_dummy_rdma(mgp, 0);
@@ -4189,7 +4189,7 @@
 #endif
 };
 
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 static int
 myri10ge_notify_dca(struct notifier_block *nb, unsigned long event, void *p)
 {
@@ -4220,7 +4220,7 @@
 		       myri10ge_driver.name, myri10ge_rss_hash);
 		myri10ge_rss_hash = MXGEFW_RSS_HASH_TYPE_SRC_PORT;
 	}
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	dca_register_notify(&myri10ge_dca_notifier);
 #endif
 	if (myri10ge_max_slices > MYRI10GE_MAX_SLICES)
@@ -4233,7 +4233,7 @@
 
 static __exit void myri10ge_cleanup_module(void)
 {
-#ifdef CONFIG_DCA
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
 	dca_unregister_notify(&myri10ge_dca_notifier);
 #endif
 	pci_unregister_driver(&myri10ge_driver);


