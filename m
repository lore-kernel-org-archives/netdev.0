From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 6/6][ATM]: assorted cleanups
Date: Tue, 22 Mar 2005 19:57:12 -0500
Message-ID: <200503230057.j2N0vBlq028423@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/22 15:26:29-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/raw.c
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/protocols.h
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +0 -2
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/pppoatm.c
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/mpc.h
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +0 -4
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/mpc.c
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +3 -3
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/lec_arpc.h
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +0 -24
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/lec.h
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +0 -9
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/lec.c
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +45 -38
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/common.c
#   2005/03/22 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: assorted cleanups
#   
#   Signed-off-by: Adrian Bunk <bunk@stusta.de>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	2005-03-22 19:49:03 -05:00
+++ b/net/atm/common.c	2005-03-22 19:49:03 -05:00
@@ -41,7 +41,7 @@
 struct hlist_head vcc_hash[VCC_HTABLE_SIZE];
 DEFINE_RWLOCK(vcc_sklist_lock);
 
-void __vcc_insert_socket(struct sock *sk)
+static void __vcc_insert_socket(struct sock *sk)
 {
 	struct atm_vcc *vcc = atm_sk(sk);
 	struct hlist_head *head = &vcc_hash[vcc->vci &
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	2005-03-22 19:49:03 -05:00
+++ b/net/atm/lec.c	2005-03-22 19:49:03 -05:00
@@ -80,6 +80,29 @@
 static int lane2_associate_req (struct net_device *dev, u8 *lan_dst,
                          u8 *tlvs, u32 sizeoftlvs);
 
+static int lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr, 
+			   unsigned long permanent);
+static void lec_arp_check_empties(struct lec_priv *priv,
+				  struct atm_vcc *vcc, struct sk_buff *skb);
+static void lec_arp_destroy(struct lec_priv *priv);
+static void lec_arp_init(struct lec_priv *priv);
+static struct atm_vcc* lec_arp_resolve(struct lec_priv *priv,
+				       unsigned char *mac_to_find,
+				       int is_rdesc,
+				       struct lec_arp_table **ret_entry);
+static void lec_arp_update(struct lec_priv *priv, unsigned char *mac_addr,
+			   unsigned char *atm_addr, unsigned long remoteflag,
+			   unsigned int targetless_le_arp);
+static void lec_flush_complete(struct lec_priv *priv, unsigned long tran_id);
+static int lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc);
+static void lec_set_flush_tran_id(struct lec_priv *priv,
+				  unsigned char *atm_addr,
+				  unsigned long tran_id);
+static void lec_vcc_added(struct lec_priv *priv, struct atmlec_ioc *ioc_data,
+			  struct atm_vcc *vcc,
+			  void (*old_push)(struct atm_vcc *vcc, struct sk_buff *skb));
+static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc);
+
 static struct lane2_ops lane2_ops = {
 	lane2_resolve,         /* resolve,             spec 3.1.3 */
 	lane2_associate_req,   /* associate_req,       spec 3.1.4 */
@@ -91,21 +114,6 @@
 /* Device structures */
 static struct net_device *dev_lec[MAX_LEC_ITF];
 
-/* This will be called from proc.c via function pointer */
-struct net_device *get_dev_lec(int itf)
-{
-	struct net_device *dev;
-
-	if (itf >= MAX_LEC_ITF)
-		return NULL;
-	rtnl_lock();
-	dev = dev_lec[itf];
-	if (dev)
-		dev_hold(dev);
-	rtnl_unlock();
-	return dev;
-}
-
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 {
@@ -152,7 +160,7 @@
  * and returns NULL.
  */
 #ifdef CONFIG_TR
-unsigned char *get_tr_dst(unsigned char *packet, unsigned char *rdesc)
+static unsigned char *get_tr_dst(unsigned char *packet, unsigned char *rdesc)
 {
         struct trh_hdr *trh;
         int riflen, num_rdsc;
@@ -596,7 +604,7 @@
  * LANE2: new argument struct sk_buff *data contains
  * the LE_ARP based TLVs introduced in the LANE2 spec
  */
-int 
+static int 
 send_to_lecd(struct lec_priv *priv, atmlec_msg_type type, 
              unsigned char *mac_addr, unsigned char *atm_addr,
              struct sk_buff *data)
@@ -678,7 +686,7 @@
         0x01,
         0x01 };
 
-void 
+static void 
 lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 {
         struct net_device *dev = (struct net_device *)vcc->proto_data;
@@ -761,7 +769,7 @@
         }
 }
 
-void
+static void
 lec_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
@@ -781,7 +789,7 @@
 	}
 }
 
-int 
+static int 
 lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 {
 	struct lec_vcc_priv *vpriv;
@@ -810,7 +818,7 @@
         return 0;
 }
 
-int 
+static int 
 lec_mcast_attach(struct atm_vcc *vcc, int arg)
 {
         if (arg <0 || arg >= MAX_LEC_ITF || !dev_lec[arg])
@@ -820,7 +828,7 @@
 }
 
 /* Initialize device. */
-int 
+static int 
 lecd_attach(struct atm_vcc *vcc, int arg)
 {  
         int i;
@@ -1380,7 +1388,6 @@
 
 static void lec_arp_check_expire(unsigned long data);
 static void lec_arp_expire_arp(unsigned long data);
-void dump_arp_table(struct lec_priv *priv);
 
 /* 
  * Arp table funcs
@@ -1391,7 +1398,7 @@
 /*
  * Initialization of arp-cache
  */
-void 
+static void 
 lec_arp_init(struct lec_priv *priv)
 {
         unsigned short i;
@@ -1407,7 +1414,7 @@
         add_timer(&priv->lec_arp_timer);
 }
 
-void
+static void
 lec_arp_clear_vccs(struct lec_arp_table *entry)
 {
         if (entry->vcc) {
@@ -1536,7 +1543,7 @@
 }
 #endif
 
-void
+static void
 dump_arp_table(struct lec_priv *priv)
 {
 #if DEBUG_ARP_TABLE
@@ -1688,7 +1695,7 @@
 /*
  * Destruction of arp-cache
  */
-void
+static void
 lec_arp_destroy(struct lec_priv *priv)
 {
 	unsigned long flags;
@@ -1950,9 +1957,9 @@
  * Try to find vcc where mac_address is attached.
  * 
  */
-struct atm_vcc*
-lec_arp_resolve(struct lec_priv *priv, unsigned char *mac_to_find, int is_rdesc,
-                struct lec_arp_table **ret_entry)
+static struct atm_vcc*
+lec_arp_resolve(struct lec_priv *priv, unsigned char *mac_to_find,
+		int is_rdesc, struct lec_arp_table **ret_entry)
 {
 	unsigned long flags;
         struct lec_arp_table *entry;
@@ -2031,7 +2038,7 @@
 	return found;
 }
 
-int
+static int
 lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr, 
                 unsigned long permanent)
 {
@@ -2061,7 +2068,7 @@
 /*
  * Notifies:  Response to arp_request (atm_addr != NULL) 
  */
-void
+static void
 lec_arp_update(struct lec_priv *priv, unsigned char *mac_addr,
                unsigned char *atm_addr, unsigned long remoteflag,
                unsigned int targetless_le_arp)
@@ -2173,7 +2180,7 @@
 /*
  * Notifies: Vcc setup ready 
  */
-void
+static void
 lec_vcc_added(struct lec_priv *priv, struct atmlec_ioc *ioc_data,
               struct atm_vcc *vcc,
               void (*old_push)(struct atm_vcc *vcc, struct sk_buff *skb))
@@ -2317,7 +2324,7 @@
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
-void
+static void
 lec_flush_complete(struct lec_priv *priv, unsigned long tran_id)
 {
 	unsigned long flags;
@@ -2343,7 +2350,7 @@
         dump_arp_table(priv);
 }
 
-void
+static void
 lec_set_flush_tran_id(struct lec_priv *priv,
                       unsigned char *atm_addr, unsigned long tran_id)
 {
@@ -2361,7 +2368,7 @@
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
-int 
+static int 
 lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc)
 {
 	unsigned long flags;
@@ -2398,7 +2405,7 @@
         return err;
 }
 
-void
+static void
 lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc)
 {
 	unsigned long flags;
@@ -2473,7 +2480,7 @@
 	dump_arp_table(priv);
 }
 
-void
+static void
 lec_arp_check_empties(struct lec_priv *priv,
                       struct atm_vcc *vcc, struct sk_buff *skb)
 {
diff -Nru a/net/atm/lec.h b/net/atm/lec.h
--- a/net/atm/lec.h	2005-03-22 19:49:03 -05:00
+++ b/net/atm/lec.h	2005-03-22 19:49:03 -05:00
@@ -138,14 +138,5 @@
 
 #define LEC_VCC_PRIV(vcc)	((struct lec_vcc_priv *)((vcc)->user_back))
 
-int lecd_attach(struct atm_vcc *vcc, int arg);
-int lec_vcc_attach(struct atm_vcc *vcc, void __user *arg);
-int lec_mcast_attach(struct atm_vcc *vcc, int arg);
-struct net_device *get_dev_lec(int itf);
-int send_to_lecd(struct lec_priv *priv,
-                 atmlec_msg_type type, unsigned char *mac_addr,
-                 unsigned char *atm_addr, struct sk_buff *data);
-void lec_push(struct atm_vcc *vcc, struct sk_buff *skb);
-
 #endif /* _LEC_H_ */
 
diff -Nru a/net/atm/lec_arpc.h b/net/atm/lec_arpc.h
--- a/net/atm/lec_arpc.h	2005-03-22 19:49:03 -05:00
+++ b/net/atm/lec_arpc.h	2005-03-22 19:49:03 -05:00
@@ -89,28 +89,4 @@
 #define LEC_REMOTE_FLAG      0x0001
 #define LEC_PERMANENT_FLAG   0x0002
 
-/* Protos */
-void lec_arp_init(struct lec_priv *priv);
-int lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc);
-void lec_arp_destroy(struct lec_priv *priv);
-void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc);
-
-struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
-                                unsigned char *mac_to_addr,
-                                int is_rdesc,
-                                struct lec_arp_table **ret_entry);
-void lec_vcc_added(struct lec_priv *dev,
-                   struct atmlec_ioc *ioc_data, struct atm_vcc *vcc,
-                   void (*old_push)(struct atm_vcc *vcc, struct sk_buff *skb));
-void lec_arp_check_empties(struct lec_priv *priv,
-                           struct atm_vcc *vcc, struct sk_buff *skb);
-int lec_addr_delete(struct lec_priv *priv,
-                    unsigned char *mac_addr, unsigned long permanent);
-void lec_flush_complete(struct lec_priv *priv, unsigned long tran_id);
-void lec_arp_update(struct lec_priv *priv,
-                    unsigned char *mac_addr, unsigned char *atm_addr,
-                    unsigned long remoteflag, unsigned int targetless_le_arp);
-void lec_set_flush_tran_id(struct lec_priv *priv,
-                           unsigned char *mac_addr, unsigned long tran_id);
-
 #endif
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	2005-03-22 19:49:03 -05:00
+++ b/net/atm/mpc.c	2005-03-22 19:49:03 -05:00
@@ -564,7 +564,7 @@
 	return retval;
 }
 
-int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
+static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 {
 	int bytes_left;
 	struct mpoa_client *mpc;
@@ -753,7 +753,7 @@
 	/* members not explicitly initialised will be 0 */
 };
 
-int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
+static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
 {
 	struct mpoa_client *mpc;
 	struct lec_priv *priv;
@@ -1460,7 +1460,7 @@
 	return 0;
 }
 
-void __exit atm_mpoa_cleanup(void)
+static void __exit atm_mpoa_cleanup(void)
 {
 	struct mpoa_client *mpc, *tmp;
 	struct atm_mpoa_qos *qos, *nextqos;
diff -Nru a/net/atm/mpc.h b/net/atm/mpc.h
--- a/net/atm/mpc.h	2005-03-22 19:49:03 -05:00
+++ b/net/atm/mpc.h	2005-03-22 19:49:03 -05:00
@@ -11,10 +11,6 @@
 /* kernel -> mpc-daemon */
 int msg_to_mpoad(struct k_message *msg, struct mpoa_client *mpc);
 
-/* Functions for ioctl(ATMMPC_*) operations */
-int atm_mpoa_mpoad_attach(struct atm_vcc *vcc, int arg);
-int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg);
-
 struct mpoa_client {
         struct mpoa_client *next;
         struct net_device *dev;      /* lec in question                     */
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	2005-03-22 19:49:03 -05:00
+++ b/net/atm/pppoatm.c	2005-03-22 19:49:03 -05:00
@@ -345,7 +345,7 @@
 	return -ENOIOCTLCMD;
 }
 
-struct atm_ioctl pppoatm_ioctl_ops = {
+static struct atm_ioctl pppoatm_ioctl_ops = {
 	.owner	= THIS_MODULE,
 	.ioctl	= pppoatm_ioctl,
 };
diff -Nru a/net/atm/protocols.h b/net/atm/protocols.h
--- a/net/atm/protocols.h	2005-03-22 19:49:03 -05:00
+++ b/net/atm/protocols.h	2005-03-22 19:49:03 -05:00
@@ -6,8 +6,6 @@
 #ifndef NET_ATM_PROTOCOLS_H
 #define NET_ATM_PROTOCOLS_H
 
-void atm_push_raw(struct atm_vcc *vcc,struct sk_buff *skb);
-
 int atm_init_aal0(struct atm_vcc *vcc);	/* "raw" AAL0 */
 int atm_init_aal34(struct atm_vcc *vcc);/* "raw" AAL3/4 transport */
 int atm_init_aal5(struct atm_vcc *vcc);	/* "raw" AAL5 transport */
diff -Nru a/net/atm/raw.c b/net/atm/raw.c
--- a/net/atm/raw.c	2005-03-22 19:49:03 -05:00
+++ b/net/atm/raw.c	2005-03-22 19:49:03 -05:00
@@ -25,7 +25,7 @@
  * SKB == NULL indicates that the link is being closed
  */
 
-void atm_push_raw(struct atm_vcc *vcc,struct sk_buff *skb)
+static void atm_push_raw(struct atm_vcc *vcc,struct sk_buff *skb)
 {
 	if (skb) {
 		struct sock *sk = sk_atm(vcc);
