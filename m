From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6 3/6] atm: use const where reasonable
Date: Tue, 17 Jun 2008 09:16:22 -0400
Message-ID: <200806171316.m5HDGMQp005884@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:53841 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756893AbYFQNQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:16:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 086c29e3c2f5f39708822295677f272e7061facb
Author: Mitchell Blank Jr <mitch@sfgoth.com>
Date:   Sat Jun 14 17:35:55 2008 -0400

    atm: use const where reasonable
    
    From: Mitchell Blank Jr <mitch@sfgoth.com>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/net/atm/addr.c b/net/atm/addr.c
index 6afa77d..82e85ab 100644
--- a/net/atm/addr.c
+++ b/net/atm/addr.c
@@ -9,7 +9,7 @@
 #include "signaling.h"
 #include "addr.h"
 
-static int check_addr(struct sockaddr_atmsvc *addr)
+static int check_addr(const struct sockaddr_atmsvc *addr)
 {
 	int i;
 
@@ -23,7 +23,7 @@ static int check_addr(struct sockaddr_atmsvc *addr)
 	return -EINVAL;
 }
 
-static int identical(struct sockaddr_atmsvc *a, struct sockaddr_atmsvc *b)
+static int identical(const struct sockaddr_atmsvc *a, const struct sockaddr_atmsvc *b)
 {
 	if (*a->sas_addr.prv)
 		if (memcmp(a->sas_addr.prv, b->sas_addr.prv, ATM_ESA_LEN))
@@ -35,7 +35,7 @@ static int identical(struct sockaddr_atmsvc *a, struct sockaddr_atmsvc *b)
 	return !strcmp(a->sas_addr.pub, b->sas_addr.pub);
 }
 
-static void notify_sigd(struct atm_dev *dev)
+static void notify_sigd(const struct atm_dev *dev)
 {
 	struct sockaddr_atmpvc pvc;
 
@@ -63,7 +63,7 @@ void atm_reset_addr(struct atm_dev *dev, enum atm_addr_type_t atype)
 		notify_sigd(dev);
 }
 
-int atm_add_addr(struct atm_dev *dev, struct sockaddr_atmsvc *addr,
+int atm_add_addr(struct atm_dev *dev, const struct sockaddr_atmsvc *addr,
 		 enum atm_addr_type_t atype)
 {
 	unsigned long flags;
@@ -98,7 +98,7 @@ int atm_add_addr(struct atm_dev *dev, struct sockaddr_atmsvc *addr,
 	return 0;
 }
 
-int atm_del_addr(struct atm_dev *dev, struct sockaddr_atmsvc *addr,
+int atm_del_addr(struct atm_dev *dev, const struct sockaddr_atmsvc *addr,
 		 enum atm_addr_type_t atype)
 {
 	unsigned long flags;
diff --git a/net/atm/addr.h b/net/atm/addr.h
index f39433a..6837e9e 100644
--- a/net/atm/addr.h
+++ b/net/atm/addr.h
@@ -10,9 +10,9 @@
 #include <linux/atmdev.h>
 
 void atm_reset_addr(struct atm_dev *dev, enum atm_addr_type_t type);
-int atm_add_addr(struct atm_dev *dev, struct sockaddr_atmsvc *addr,
+int atm_add_addr(struct atm_dev *dev, const struct sockaddr_atmsvc *addr,
 		 enum atm_addr_type_t type);
-int atm_del_addr(struct atm_dev *dev, struct sockaddr_atmsvc *addr,
+int atm_del_addr(struct atm_dev *dev, const struct sockaddr_atmsvc *addr,
 		 enum atm_addr_type_t type);
 int atm_get_addr(struct atm_dev *dev, struct sockaddr_atmsvc __user *buf,
 		 size_t size, enum atm_addr_type_t type);
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 05fafdc..8d9a6f1 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -52,12 +52,12 @@ static void skb_debug(const struct sk_buff *skb)
 #define ETHERTYPE_IPV6	0x86, 0xdd
 #define PAD_BRIDGED	0x00, 0x00
 
-static unsigned char ethertype_ipv4[] = { ETHERTYPE_IPV4 };
-static unsigned char ethertype_ipv6[] = { ETHERTYPE_IPV6 };
-static unsigned char llc_oui_pid_pad[] =
+static const unsigned char ethertype_ipv4[] = { ETHERTYPE_IPV4 };
+static const unsigned char ethertype_ipv6[] = { ETHERTYPE_IPV6 };
+static const unsigned char llc_oui_pid_pad[] =
 			{ LLC, SNAP_BRIDGED, PID_ETHERNET, PAD_BRIDGED };
-static unsigned char llc_oui_ipv4[] = { LLC, SNAP_ROUTED, ETHERTYPE_IPV4 };
-static unsigned char llc_oui_ipv6[] = { LLC, SNAP_ROUTED, ETHERTYPE_IPV6 };
+static const unsigned char llc_oui_ipv4[] = { LLC, SNAP_ROUTED, ETHERTYPE_IPV4 };
+static const unsigned char llc_oui_ipv6[] = { LLC, SNAP_ROUTED, ETHERTYPE_IPV6 };
 
 enum br2684_encaps {
 	e_vc = BR2684_ENCAPS_VC,
@@ -217,8 +217,8 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
 	return 1;
 }
 
-static inline struct br2684_vcc *pick_outgoing_vcc(struct sk_buff *skb,
-						   struct br2684_dev *brdev)
+static inline struct br2684_vcc *pick_outgoing_vcc(const struct sk_buff *skb,
+						   const struct br2684_dev *brdev)
 {
 	return list_empty(&brdev->brvccs) ? NULL : list_entry_brvcc(brdev->brvccs.next);	/* 1 vcc/dev right now */
 }
diff --git a/net/atm/common.c b/net/atm/common.c
index 843cae4..78fbbf2 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -261,7 +261,7 @@ static int adjust_tp(struct atm_trafprm *tp,unsigned char aal)
 }
 
 
-static int check_ci(struct atm_vcc *vcc, short vpi, int vci)
+static int check_ci(const struct atm_vcc *vcc, short vpi, int vci)
 {
 	struct hlist_head *head = &vcc_hash[vci &
 					(VCC_HTABLE_SIZE - 1)];
@@ -289,7 +289,7 @@ static int check_ci(struct atm_vcc *vcc, short vpi, int vci)
 }
 
 
-static int find_ci(struct atm_vcc *vcc, short *vpi, int *vci)
+static int find_ci(const struct atm_vcc *vcc, short *vpi, int *vci)
 {
 	static short p;        /* poor man's per-device cache */
 	static int c;
@@ -637,7 +637,7 @@ static int atm_change_qos(struct atm_vcc *vcc,struct atm_qos *qos)
 }
 
 
-static int check_tp(struct atm_trafprm *tp)
+static int check_tp(const struct atm_trafprm *tp)
 {
 	/* @@@ Should be merged with adjust_tp */
 	if (!tp->traffic_class || tp->traffic_class == ATM_ANYCLASS) return 0;
@@ -654,7 +654,7 @@ static int check_tp(struct atm_trafprm *tp)
 }
 
 
-static int check_qos(struct atm_qos *qos)
+static int check_qos(const struct atm_qos *qos)
 {
 	int error;
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index bb506c0..d169002 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -65,36 +65,36 @@ static int lec_close(struct net_device *dev);
 static struct net_device_stats *lec_get_stats(struct net_device *dev);
 static void lec_init(struct net_device *dev);
 static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
-					  unsigned char *mac_addr);
+					  const unsigned char *mac_addr);
 static int lec_arp_remove(struct lec_priv *priv,
 			  struct lec_arp_table *to_remove);
 /* LANE2 functions */
-static void lane2_associate_ind(struct net_device *dev, u8 *mac_address,
-				u8 *tlvs, u32 sizeoftlvs);
-static int lane2_resolve(struct net_device *dev, u8 *dst_mac, int force,
+static void lane2_associate_ind(struct net_device *dev, const u8 *mac_address,
+				const u8 *tlvs, u32 sizeoftlvs);
+static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 			 u8 **tlvs, u32 *sizeoftlvs);
-static int lane2_associate_req(struct net_device *dev, u8 *lan_dst,
-			       u8 *tlvs, u32 sizeoftlvs);
+static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
+			       const u8 *tlvs, u32 sizeoftlvs);
 
-static int lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr,
+static int lec_addr_delete(struct lec_priv *priv, const unsigned char *atm_addr,
 			   unsigned long permanent);
 static void lec_arp_check_empties(struct lec_priv *priv,
 				  struct atm_vcc *vcc, struct sk_buff *skb);
 static void lec_arp_destroy(struct lec_priv *priv);
 static void lec_arp_init(struct lec_priv *priv);
 static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
-				       unsigned char *mac_to_find,
+				       const unsigned char *mac_to_find,
 				       int is_rdesc,
 				       struct lec_arp_table **ret_entry);
-static void lec_arp_update(struct lec_priv *priv, unsigned char *mac_addr,
-			   unsigned char *atm_addr, unsigned long remoteflag,
+static void lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
+			   const unsigned char *atm_addr, unsigned long remoteflag,
 			   unsigned int targetless_le_arp);
 static void lec_flush_complete(struct lec_priv *priv, unsigned long tran_id);
 static int lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc);
 static void lec_set_flush_tran_id(struct lec_priv *priv,
-				  unsigned char *atm_addr,
+				  const unsigned char *atm_addr,
 				  unsigned long tran_id);
-static void lec_vcc_added(struct lec_priv *priv, struct atmlec_ioc *ioc_data,
+static void lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 			  struct atm_vcc *vcc,
 			  void (*old_push) (struct atm_vcc *vcc,
 					    struct sk_buff *skb));
@@ -634,7 +634,7 @@ static struct atm_dev lecatm_dev = {
  */
 static int
 send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
-	     unsigned char *mac_addr, unsigned char *atm_addr,
+	     const unsigned char *mac_addr, const unsigned char *atm_addr,
 	     struct sk_buff *data)
 {
 	struct sock *sk;
@@ -705,10 +705,9 @@ static void lec_init(struct net_device *dev)
 	dev->set_multicast_list = lec_set_multicast_list;
 	dev->do_ioctl = NULL;
 	printk("%s: Initialized!\n", dev->name);
-	return;
 }
 
-static unsigned char lec_ctrl_magic[] = {
+static const unsigned char lec_ctrl_magic[] = {
 	0xff,
 	0x00,
 	0x01,
@@ -1275,7 +1274,7 @@ module_exit(lane_module_cleanup);
  * lec will be used.
  * If dst_mac == NULL, targetless LE_ARP will be sent
  */
-static int lane2_resolve(struct net_device *dev, u8 *dst_mac, int force,
+static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 			 u8 **tlvs, u32 *sizeoftlvs)
 {
 	unsigned long flags;
@@ -1321,8 +1320,8 @@ static int lane2_resolve(struct net_device *dev, u8 *dst_mac, int force,
  * Returns 1 for success, 0 for failure (out of memory)
  *
  */
-static int lane2_associate_req(struct net_device *dev, u8 *lan_dst,
-			       u8 *tlvs, u32 sizeoftlvs)
+static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
+			       const u8 *tlvs, u32 sizeoftlvs)
 {
 	int retval;
 	struct sk_buff *skb;
@@ -1357,8 +1356,8 @@ static int lane2_associate_req(struct net_device *dev, u8 *lan_dst,
  * LANE2: 3.1.5, LE_ASSOCIATE.indication
  *
  */
-static void lane2_associate_ind(struct net_device *dev, u8 *mac_addr,
-				u8 *tlvs, u32 sizeoftlvs)
+static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
+				const u8 *tlvs, u32 sizeoftlvs)
 {
 #if 0
 	int i = 0;
@@ -1743,7 +1742,7 @@ static void lec_arp_destroy(struct lec_priv *priv)
  * Find entry by mac_address
  */
 static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
-					  unsigned char *mac_addr)
+					  const unsigned char *mac_addr)
 {
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -1763,7 +1762,7 @@ static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
 }
 
 static struct lec_arp_table *make_entry(struct lec_priv *priv,
-					unsigned char *mac_addr)
+					const unsigned char *mac_addr)
 {
 	struct lec_arp_table *to_return;
 
@@ -1920,7 +1919,7 @@ restart:
  *
  */
 static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
-				       unsigned char *mac_to_find, int is_rdesc,
+				       const unsigned char *mac_to_find, int is_rdesc,
 				       struct lec_arp_table **ret_entry)
 {
 	unsigned long flags;
@@ -2016,7 +2015,7 @@ out:
 }
 
 static int
-lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr,
+lec_addr_delete(struct lec_priv *priv, const unsigned char *atm_addr,
 		unsigned long permanent)
 {
 	unsigned long flags;
@@ -2046,8 +2045,8 @@ lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr,
  * Notifies:  Response to arp_request (atm_addr != NULL)
  */
 static void
-lec_arp_update(struct lec_priv *priv, unsigned char *mac_addr,
-	       unsigned char *atm_addr, unsigned long remoteflag,
+lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
+	       const unsigned char *atm_addr, unsigned long remoteflag,
 	       unsigned int targetless_le_arp)
 {
 	unsigned long flags;
@@ -2147,7 +2146,7 @@ out:
  * Notifies: Vcc setup ready
  */
 static void
-lec_vcc_added(struct lec_priv *priv, struct atmlec_ioc *ioc_data,
+lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 	      struct atm_vcc *vcc,
 	      void (*old_push) (struct atm_vcc *vcc, struct sk_buff *skb))
 {
@@ -2335,7 +2334,7 @@ restart:
 
 static void
 lec_set_flush_tran_id(struct lec_priv *priv,
-		      unsigned char *atm_addr, unsigned long tran_id)
+		      const unsigned char *atm_addr, unsigned long tran_id)
 {
 	unsigned long flags;
 	struct hlist_node *node;
diff --git a/net/atm/lec.h b/net/atm/lec.h
index b41cda7..0d37668 100644
--- a/net/atm/lec.h
+++ b/net/atm/lec.h
@@ -42,12 +42,12 @@ struct lecdatahdr_8025 {
  *
  */
 struct lane2_ops {
-	int (*resolve) (struct net_device *dev, u8 *dst_mac, int force,
+	int (*resolve) (struct net_device *dev, const u8 *dst_mac, int force,
 			u8 **tlvs, u32 *sizeoftlvs);
-	int (*associate_req) (struct net_device *dev, u8 *lan_dst,
-			      u8 *tlvs, u32 sizeoftlvs);
-	void (*associate_indicator) (struct net_device *dev, u8 *mac_addr,
-				     u8 *tlvs, u32 sizeoftlvs);
+	int (*associate_req) (struct net_device *dev, const u8 *lan_dst,
+			      const u8 *tlvs, u32 sizeoftlvs);
+	void (*associate_indicator) (struct net_device *dev, const u8 *mac_addr,
+				     const u8 *tlvs, u32 sizeoftlvs);
 };
 
 /*
