From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/19] convert ATM drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:42 -0700
Message-ID: <20090901055128.667103600@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34270 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752803AbZIAGA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 02:00:57 -0400
Content-Disposition: inline; filename=atm-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/atm/br2684.c |    3 ++-
 net/atm/clip.c   |    3 ++-
 net/atm/lec.c    |    6 ++++--
 net/atm/mpc.c    |    6 ++++--
 4 files changed, 12 insertions(+), 6 deletions(-)

--- a/net/atm/br2684.c	2009-08-31 16:17:53.441108407 -0700
+++ b/net/atm/br2684.c	2009-08-31 16:24:25.021124362 -0700
@@ -223,7 +223,8 @@ static inline struct br2684_vcc *pick_ou
 	return list_empty(&brdev->brvccs) ? NULL : list_entry_brvcc(brdev->brvccs.next);	/* 1 vcc/dev right now */
 }
 
-static int br2684_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t br2684_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	struct br2684_dev *brdev = BRPRIV(dev);
 	struct br2684_vcc *brvcc;
--- a/net/atm/clip.c	2009-08-31 16:17:53.421109008 -0700
+++ b/net/atm/clip.c	2009-08-31 16:25:00.891106292 -0700
@@ -360,7 +360,8 @@ static int clip_encap(struct atm_vcc *vc
 	return 0;
 }
 
-static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
+				   struct net_device *dev)
 {
 	struct clip_priv *clip_priv = PRIV(dev);
 	struct atmarp_entry *entry;
--- a/net/atm/lec.c	2009-08-31 16:17:53.421109008 -0700
+++ b/net/atm/lec.c	2009-08-31 16:24:47.171086012 -0700
@@ -59,7 +59,8 @@ static unsigned char bridge_ula_lec[] = 
 				 */
 
 static int lec_open(struct net_device *dev);
-static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev);
 static int lec_close(struct net_device *dev);
 static void lec_init(struct net_device *dev);
 static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
@@ -247,7 +248,8 @@ static void lec_tx_timeout(struct net_de
 	netif_wake_queue(dev);
 }
 
-static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
+				  struct net_device *dev)
 {
 	struct sk_buff *skb2;
 	struct lec_priv *priv = netdev_priv(dev);
--- a/net/atm/mpc.c	2009-08-31 16:17:53.431133326 -0700
+++ b/net/atm/mpc.c	2009-08-31 16:23:53.813602657 -0700
@@ -73,7 +73,8 @@ static void mpoad_close(struct atm_vcc *
 static int msg_from_mpoad(struct atm_vcc *vcc, struct sk_buff *skb);
 
 static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb);
-static int mpc_send_packet(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
+					 struct net_device *dev);
 static int mpoa_event_listener(struct notifier_block *mpoa_notifier, unsigned long event, void *dev);
 static void mpc_timer_refresh(void);
 static void mpc_cache_check( unsigned long checking_time  );
@@ -528,7 +529,8 @@ static int send_via_shortcut(struct sk_b
 /*
  * Probably needs some error checks and locking, not sure...
  */
-static int mpc_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
+					 struct net_device *dev)
 {
 	struct mpoa_client *mpc;
 	struct ethhdr *eth;

-- 

