From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] napi: conditional NAPI in drivers
Date: Wed, 21 Nov 2007 15:08:31 -0800
Message-ID: <20071121150831.145c4ec7@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47996 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754694AbXKUXPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:15:03 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There has been a pattern of bugs in the 2.6.24 conversion
where a driver is broken if NAPI is not configured.

Change all drivers that have conditional NAPI option to
have the datastructure missing so these bugs are caught at compile
time.

Compile tested only (but that's the point).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/amd8111e.h       |    2 ++
 drivers/net/cassini.h        |    3 ++-
 drivers/net/chelsio/common.h |    2 ++
 drivers/net/forcedeth.c      |    3 ++-
 drivers/net/gianfar.h        |    2 ++
 drivers/net/ixgb/ixgb.h      |    2 ++
 drivers/net/pcnet32.c        |    2 ++
 drivers/net/s2io.h           |    2 ++
 drivers/net/starfire.c       |    2 ++
 drivers/net/ucc_geth.h       |    2 ++
 drivers/net/via-rhine.c      |    2 ++
 11 files changed, 22 insertions(+), 2 deletions(-)

--- a/drivers/net/amd8111e.h	2007-11-16 16:17:20.000000000 -0800
+++ b/drivers/net/amd8111e.h	2007-11-21 10:04:20.000000000 -0800
@@ -763,7 +763,9 @@ struct amd8111e_priv{
 	/* Reg memory mapped address */
 	void __iomem *mmio;
 
+#ifdef CONFIG_AMD8111E_NAPI
 	struct napi_struct napi;
+#endif
 
 	spinlock_t lock;	/* Guard lock */
 	unsigned long rx_idx, tx_idx;	/* The next free ring entry */
--- a/drivers/net/cassini.h	2007-11-16 16:17:20.000000000 -0800
+++ b/drivers/net/cassini.h	2007-11-21 10:07:25.000000000 -0800
@@ -4280,8 +4280,9 @@ struct cas {
 	int rx_cur[N_RX_COMP_RINGS], rx_new[N_RX_COMP_RINGS];
 	int rx_last[N_RX_DESC_RINGS];
 
+#ifdef CONFIG_CASSINI_NAPI
 	struct napi_struct napi;
-
+#endif
 	/* Set when chip is actually in operational state
 	 * (ie. not power managed) */
 	int hw_running;
--- a/drivers/net/chelsio/common.h	2007-11-16 16:17:20.000000000 -0800
+++ b/drivers/net/chelsio/common.h	2007-11-21 10:15:09.000000000 -0800
@@ -278,7 +278,9 @@ struct adapter {
 	struct peespi *espi;
 	struct petp   *tp;
 
+#ifdef CONFIG_CHELSIO_T1_NAPI
 	struct napi_struct napi;
+#endif
 	struct port_info port[MAX_NPORTS];
 	struct delayed_work stats_update_task;
 	struct timer_list stats_update_timer;
--- a/drivers/net/forcedeth.c	2007-11-19 18:56:12.000000000 -0800
+++ b/drivers/net/forcedeth.c	2007-11-21 10:10:43.000000000 -0800
@@ -748,8 +748,9 @@ struct fe_priv {
 	spinlock_t lock;
 
 	struct net_device *dev;
+#ifdef CONFIG_FORCEDETH_NAPI
 	struct napi_struct napi;
-
+#endif
 	/* General data:
 	 * Locking: spin_lock(&np->lock); */
 	struct nv_ethtool_stats estats;
--- a/drivers/net/gianfar.h	2007-11-16 16:17:20.000000000 -0800
+++ b/drivers/net/gianfar.h	2007-11-21 10:13:25.000000000 -0800
@@ -691,7 +691,9 @@ struct gfar_private {
 	spinlock_t rxlock;
 
 	struct net_device *dev;
+#ifdef CONFIG_GFAR_NAPI
 	struct napi_struct napi;
+#endif
 
 	/* skb array and index */
 	struct sk_buff ** rx_skbuff;
--- a/drivers/net/ixgb/ixgb.h	2007-11-19 18:56:12.000000000 -0800
+++ b/drivers/net/ixgb/ixgb.h	2007-11-21 10:15:41.000000000 -0800
@@ -184,7 +184,9 @@ struct ixgb_adapter {
 	boolean_t rx_csum;
 
 	/* OS defined structs */
+#ifdef CONFIG_IXGB_NAPI
 	struct napi_struct napi;
+#endif
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
--- a/drivers/net/starfire.c	2007-11-16 16:17:21.000000000 -0800
+++ b/drivers/net/starfire.c	2007-11-21 10:10:13.000000000 -0800
@@ -596,7 +596,9 @@ struct netdev_private {
 	struct tx_done_desc *tx_done_q;
 	dma_addr_t tx_done_q_dma;
 	unsigned int tx_done;
+#ifdef CONFIG_ADAPTEC_STARFIRE_NAPI
 	struct napi_struct napi;
+#endif
 	struct net_device *dev;
 	struct net_device_stats stats;
 	struct pci_dev *pci_dev;
--- a/drivers/net/ucc_geth.h	2007-11-16 16:17:21.000000000 -0800
+++ b/drivers/net/ucc_geth.h	2007-11-21 10:14:04.000000000 -0800
@@ -1185,7 +1185,9 @@ struct ucc_geth_private {
 	struct ucc_geth_info *ug_info;
 	struct ucc_fast_private *uccf;
 	struct net_device *dev;
+#ifdef CONFIG_UGETH_NAPI
 	struct napi_struct napi;
+#endif
 	struct ucc_geth *ug_regs;
 	struct ucc_geth_init_pram *p_init_enet_param_shadow;
 	struct ucc_geth_exf_global_pram *p_exf_glbl_param;
--- a/drivers/net/via-rhine.c	2007-11-16 16:17:21.000000000 -0800
+++ b/drivers/net/via-rhine.c	2007-11-21 10:11:14.000000000 -0800
@@ -390,7 +390,9 @@ struct rhine_private {
 	struct pci_dev *pdev;
 	long pioaddr;
 	struct net_device *dev;
+#ifdef CONFIG_VIA_RHINE_NAPI
 	struct napi_struct napi;
+#endif
 	struct net_device_stats stats;
 	spinlock_t lock;
 
--- a/drivers/net/tulip/tulip.h	2007-11-16 16:17:21.000000000 -0800
+++ b/drivers/net/tulip/tulip.h	2007-11-21 10:23:38.000000000 -0800
@@ -353,7 +353,9 @@ struct tulip_private {
 	int chip_id;
 	int revision;
 	int flags;
+#ifdef CONFIG_TULIP_NAPI
 	struct napi_struct napi;
+#endif
 	struct net_device_stats stats;
 	struct timer_list timer;	/* Media selection timer. */
 	struct timer_list oom_timer;    /* Out of memory timer. */
