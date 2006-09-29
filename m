From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/8][ATM]: [lec] header indent, comment and whitespace cleanup
Date: Fri, 29 Sep 2006 12:39:40 -0400
Message-ID: <200609291639.k8TGdeVo025534@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:55260 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1161206AbWI2QkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:40:16 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [lec] header indent, comment and whitespace cleanup

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit ad9e9d30230b99dd41921b61a506c41e168e1a84
tree cc1e31605aaf3d473c4f3c8e26d9a1f9b98e72b7
parent 55300d040155e883eb8d3dd39d381c95080719e6
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:18:44 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:18:44 -0400

 include/linux/atmlec.h |  119 ++++++++++++++++++---------------
 net/atm/lec.h          |  172 ++++++++++++++++++++++++++----------------------
 net/atm/lec_arpc.h     |  148 +++++++++++++++++++++--------------------
 3 files changed, 235 insertions(+), 204 deletions(-)

diff --git a/include/linux/atmlec.h b/include/linux/atmlec.h
index f267f24..e7f1a75 100644
--- a/include/linux/atmlec.h
+++ b/include/linux/atmlec.h
@@ -1,9 +1,7 @@
 /*
- * 
- * ATM Lan Emulation Daemon vs. driver interface
- *
- * mkiiskila@yahoo.com
+ * ATM Lan Emulation Daemon driver interface
  *
+ * Marko Kiiskila <mkiiskila@yahoo.com>
  */
 
 #ifndef _ATMLEC_H_
@@ -13,76 +11,87 @@ #include <linux/atmapi.h>
 #include <linux/atmioc.h>
 #include <linux/atm.h>
 #include <linux/if_ether.h>
+
 /* ATM lec daemon control socket */
-#define ATMLEC_CTRL _IO('a',ATMIOC_LANE)
-#define ATMLEC_DATA _IO('a',ATMIOC_LANE+1)
-#define ATMLEC_MCAST _IO('a',ATMIOC_LANE+2)
+#define ATMLEC_CTRL	_IO('a', ATMIOC_LANE)
+#define ATMLEC_DATA	_IO('a', ATMIOC_LANE+1)
+#define ATMLEC_MCAST	_IO('a', ATMIOC_LANE+2)
 
 /* Maximum number of LEC interfaces (tweakable) */
 #define MAX_LEC_ITF 48
 
-/* From the total of MAX_LEC_ITF, last NUM_TR_DEVS are reserved for Token Ring.
+/*
+ * From the total of MAX_LEC_ITF, last NUM_TR_DEVS are reserved for Token Ring.
  * E.g. if MAX_LEC_ITF = 48 and NUM_TR_DEVS = 8, then lec0-lec39 are for
  * Ethernet ELANs and lec40-lec47 are for Token Ring ELANS.
  */
 #define NUM_TR_DEVS 8
 
-typedef enum { 
-        l_set_mac_addr,   l_del_mac_addr, 
-        l_svc_setup, 
-        l_addr_delete,    l_topology_change, 
-        l_flush_complete, l_arp_update,
-        l_narp_req, /* LANE2 mandates the use of this */
-        l_config,         l_flush_tran_id, 
-        l_set_lecid,      l_arp_xmt,
-        l_rdesc_arp_xmt,
-        l_associate_req,
-        l_should_bridge   /* should we bridge this MAC? */
+typedef enum {
+	l_set_mac_addr,
+	l_del_mac_addr,
+	l_svc_setup,
+	l_addr_delete,
+	l_topology_change,
+	l_flush_complete,
+	l_arp_update,
+	l_narp_req,		/* LANE2 mandates the use of this */
+	l_config,
+	l_flush_tran_id,
+	l_set_lecid,
+	l_arp_xmt,
+	l_rdesc_arp_xmt,
+	l_associate_req,
+	l_should_bridge		/* should we bridge this MAC? */
 } atmlec_msg_type;
 
 #define ATMLEC_MSG_TYPE_MAX l_should_bridge
 
 struct atmlec_config_msg {
-        unsigned int maximum_unknown_frame_count;
-        unsigned int max_unknown_frame_time;
-        unsigned short max_retry_count;
-        unsigned int aging_time;
-        unsigned int forward_delay_time;
-        unsigned int arp_response_time;
-        unsigned int flush_timeout;
-        unsigned int path_switching_delay;
-        unsigned int  lane_version; /* LANE2: 1 for LANEv1, 2 for LANEv2 */
-        int mtu;
-        int is_proxy;
+	unsigned int maximum_unknown_frame_count;
+	unsigned int max_unknown_frame_time;
+	unsigned short max_retry_count;
+	unsigned int aging_time;
+	unsigned int forward_delay_time;
+	unsigned int arp_response_time;
+	unsigned int flush_timeout;
+	unsigned int path_switching_delay;
+	unsigned int lane_version;	/* LANE2: 1 for LANEv1, 2 for LANEv2 */
+	int mtu;
+	int is_proxy;
 };
- 
+
 struct atmlec_msg {
-        atmlec_msg_type type;
-        int             sizeoftlvs;        /* LANE2: if != 0, tlvs follow */ 
-        union {
-                struct {
-                        unsigned char mac_addr[ETH_ALEN];
-                        unsigned char atm_addr[ATM_ESA_LEN];
-                        unsigned int flag;/* Topology_change flag, 
-                                              remoteflag, permanent flag,
-                                              lecid, transaction id */
-                        unsigned int targetless_le_arp; /* LANE2 */
-                        unsigned int no_source_le_narp; /* LANE2 */
-                } normal;
-                struct atmlec_config_msg config;
-                struct {
-                        uint16_t lec_id;                     /* requestor lec_id  */
-                        uint32_t tran_id;                    /* transaction id    */
-                        unsigned char mac_addr[ETH_ALEN];    /* dst mac addr      */
-                        unsigned char atm_addr[ATM_ESA_LEN]; /* reqestor ATM addr */
-                } proxy;
-		     /* For mapping LE_ARP requests to responses. Filled by */
-        } content;       /* zeppelin, returned by kernel. Used only when proxying */ 
+	atmlec_msg_type type;
+	int sizeoftlvs;		/* LANE2: if != 0, tlvs follow */
+	union {
+		struct {
+			unsigned char mac_addr[ETH_ALEN];
+			unsigned char atm_addr[ATM_ESA_LEN];
+			unsigned int flag;	/*
+						 * Topology_change flag, 
+						 * remoteflag, permanent flag,
+						 * lecid, transaction id
+						 */
+			unsigned int targetless_le_arp;	/* LANE2 */
+			unsigned int no_source_le_narp;	/* LANE2 */
+		} normal;
+		struct atmlec_config_msg config;
+		struct {
+			uint16_t lec_id;			/* requestor lec_id  */
+			uint32_t tran_id;			/* transaction id    */
+			unsigned char mac_addr[ETH_ALEN];	/* dst mac addr      */
+			unsigned char atm_addr[ATM_ESA_LEN];	/* reqestor ATM addr */
+		} proxy;	/*
+				 * For mapping LE_ARP requests to responses. Filled by
+				 * zeppelin, returned by kernel. Used only when proxying
+				 */
+	} content;
 } __ATM_API_ALIGN;
 
 struct atmlec_ioc {
-        int dev_num;
-        unsigned char atm_addr[ATM_ESA_LEN];
-        unsigned char receive;    /* 1= receive vcc, 0 = send vcc */
+	int dev_num;
+	unsigned char atm_addr[ATM_ESA_LEN];
+	unsigned char receive;	/* 1= receive vcc, 0 = send vcc */
 };
 #endif /* _ATMLEC_H_ */
diff --git a/net/atm/lec.h b/net/atm/lec.h
index c22a8bf..7efd586 100644
--- a/net/atm/lec.h
+++ b/net/atm/lec.h
@@ -1,14 +1,13 @@
 /*
- *
  * Lan Emulation client header file
  *
- * Marko Kiiskila mkiiskila@yahoo.com
- *
+ * Marko Kiiskila <mkiiskila@yahoo.com>
  */
 
 #ifndef _LEC_H_
 #define _LEC_H_
 
+#include <linux/config.h>
 #include <linux/atmdev.h>
 #include <linux/netdevice.h>
 #include <linux/atmlec.h>
@@ -16,18 +15,18 @@ #include <linux/atmlec.h>
 #define LEC_HEADER_LEN 16
 
 struct lecdatahdr_8023 {
-  unsigned short le_header;
-  unsigned char h_dest[ETH_ALEN];
-  unsigned char h_source[ETH_ALEN];
-  unsigned short h_type;
+	unsigned short le_header;
+	unsigned char h_dest[ETH_ALEN];
+	unsigned char h_source[ETH_ALEN];
+	unsigned short h_type;
 };
 
 struct lecdatahdr_8025 {
-  unsigned short le_header;
-  unsigned char ac_pad;
-  unsigned char fc;
-  unsigned char h_dest[ETH_ALEN];
-  unsigned char h_source[ETH_ALEN];
+	unsigned short le_header;
+	unsigned char ac_pad;
+	unsigned char fc;
+	unsigned char h_dest[ETH_ALEN];
+	unsigned char h_source[ETH_ALEN];
 };
 
 #define LEC_MINIMUM_8023_SIZE   62
@@ -44,17 +43,18 @@ #define LEC_MINIMUM_8025_SIZE   16
  *
  */
 struct lane2_ops {
-	int  (*resolve)(struct net_device *dev, u8 *dst_mac, int force,
-                        u8 **tlvs, u32 *sizeoftlvs);
-        int  (*associate_req)(struct net_device *dev, u8 *lan_dst,
-                              u8 *tlvs, u32 sizeoftlvs);
-	void (*associate_indicator)(struct net_device *dev, u8 *mac_addr,
-                                    u8 *tlvs, u32 sizeoftlvs);
+	int (*resolve) (struct net_device *dev, u8 *dst_mac, int force,
+			u8 **tlvs, u32 *sizeoftlvs);
+	int (*associate_req) (struct net_device *dev, u8 *lan_dst,
+			      u8 *tlvs, u32 sizeoftlvs);
+	void (*associate_indicator) (struct net_device *dev, u8 *mac_addr,
+				     u8 *tlvs, u32 sizeoftlvs);
 };
 
 /*
  * ATM LAN Emulation supports both LLC & Dix Ethernet EtherType
  * frames. 
+ *
  * 1. Dix Ethernet EtherType frames encoded by placing EtherType
  *    field in h_type field. Data follows immediatelly after header.
  * 2. LLC Data frames whose total length, including LLC field and data,
@@ -70,72 +70,88 @@ struct lane2_ops {
 #define LEC_ARP_TABLE_SIZE 16
 
 struct lec_priv {
-        struct net_device_stats stats;
-        unsigned short lecid;      /* Lecid of this client */
-        struct lec_arp_table *lec_arp_empty_ones;
-        /* Used for storing VCC's that don't have a MAC address attached yet */
-        struct lec_arp_table *lec_arp_tables[LEC_ARP_TABLE_SIZE];
-        /* Actual LE ARP table */
-        struct lec_arp_table *lec_no_forward;
-        /* Used for storing VCC's (and forward packets from) which are to
-           age out by not using them to forward packets. 
-           This is because to some LE clients there will be 2 VCCs. Only
-           one of them gets used. */
-        struct lec_arp_table *mcast_fwds;
-        /* With LANEv2 it is possible that BUS (or a special multicast server)
-           establishes multiple Multicast Forward VCCs to us. This list
-           collects all those VCCs. LANEv1 client has only one item in this
-           list. These entries are not aged out. */
-        spinlock_t lec_arp_lock;
-        struct atm_vcc *mcast_vcc; /* Default Multicast Send VCC */
-        struct atm_vcc *lecd;
-        struct timer_list lec_arp_timer;
-        /* C10 */
-        unsigned int maximum_unknown_frame_count;
-/* Within the period of time defined by this variable, the client will send 
-   no more than C10 frames to BUS for a given unicast destination. (C11) */
-        unsigned long max_unknown_frame_time;
-/* If no traffic has been sent in this vcc for this period of time,
-   vcc will be torn down (C12)*/
-        unsigned long vcc_timeout_period;
-/* An LE Client MUST not retry an LE_ARP_REQUEST for a 
-   given frame's LAN Destination more than maximum retry count times,
-   after the first LEC_ARP_REQUEST (C13)*/
-        unsigned short max_retry_count;
-/* Max time the client will maintain an entry in its arp cache in
-   absence of a verification of that relationship (C17)*/
-        unsigned long aging_time;
-/* Max time the client will maintain an entry in cache when
-   topology change flag is true (C18) */
-        unsigned long forward_delay_time;
-/* Topology change flag  (C19)*/
-        int topology_change;
-/* Max time the client expects an LE_ARP_REQUEST/LE_ARP_RESPONSE
-   cycle to take (C20)*/
-        unsigned long arp_response_time;
-/* Time limit ot wait to receive an LE_FLUSH_RESPONSE after the
-   LE_FLUSH_REQUEST has been sent before taking recover action. (C21)*/
-        unsigned long flush_timeout;
-/* The time since sending a frame to the bus after which the
-   LE Client may assume that the frame has been either discarded or
-   delivered to the recipient (C22) */
-        unsigned long path_switching_delay;
+	struct net_device_stats stats;
+	unsigned short lecid;			/* Lecid of this client */
+	struct lec_arp_table *lec_arp_empty_ones;
+						/* Used for storing VCC's that don't have a MAC address attached yet */
+	struct lec_arp_table *lec_arp_tables[LEC_ARP_TABLE_SIZE];
+						/* Actual LE ARP table */
+	struct lec_arp_table *lec_no_forward;
+						/*
+						 * Used for storing VCC's (and forward packets from) which are to
+						 * age out by not using them to forward packets. 
+						 * This is because to some LE clients there will be 2 VCCs. Only
+						 * one of them gets used.
+						 */
+	struct lec_arp_table *mcast_fwds;
+						/*
+						 * With LANEv2 it is possible that BUS (or a special multicast server)
+						 * establishes multiple Multicast Forward VCCs to us. This list
+						 * collects all those VCCs. LANEv1 client has only one item in this
+						 * list. These entries are not aged out.
+						 */
+	spinlock_t lec_arp_lock;
+	struct atm_vcc *mcast_vcc;		/* Default Multicast Send VCC */
+	struct atm_vcc *lecd;
+	struct timer_list lec_arp_timer;	/* C10 */
+	unsigned int maximum_unknown_frame_count;
+						/*
+						 * Within the period of time defined by this variable, the client will send 
+						 * no more than C10 frames to BUS for a given unicast destination. (C11)
+						 */
+	unsigned long max_unknown_frame_time;
+						/*
+						 * If no traffic has been sent in this vcc for this period of time,
+						 * vcc will be torn down (C12)
+						 */
+	unsigned long vcc_timeout_period;
+						/*
+						 * An LE Client MUST not retry an LE_ARP_REQUEST for a 
+						 * given frame's LAN Destination more than maximum retry count times,
+						 * after the first LEC_ARP_REQUEST (C13)
+						 */
+	unsigned short max_retry_count;
+						/*
+						 * Max time the client will maintain an entry in its arp cache in
+						 * absence of a verification of that relationship (C17)
+						 */
+	unsigned long aging_time;
+						/*
+						 * Max time the client will maintain an entry in cache when
+						 * topology change flag is true (C18)
+						 */
+	unsigned long forward_delay_time;	/* Topology change flag (C19) */
+	int topology_change;
+						/*
+						 * Max time the client expects an LE_ARP_REQUEST/LE_ARP_RESPONSE
+						 * cycle to take (C20)
+						 */
+	unsigned long arp_response_time;
+						/*
+						 * Time limit ot wait to receive an LE_FLUSH_RESPONSE after the
+						 * LE_FLUSH_REQUEST has been sent before taking recover action. (C21)
+						 */
+	unsigned long flush_timeout;
+						/* The time since sending a frame to the bus after which the
+						 * LE Client may assume that the frame has been either discarded or
+						 * delivered to the recipient (C22)
+						 */
+	unsigned long path_switching_delay;
 
-        u8 *tlvs;          /* LANE2: TLVs are new                */
-        u32 sizeoftlvs;    /* The size of the tlv array in bytes */
-        int lane_version;  /* LANE2                              */
-	int itfnum;        /* e.g. 2 for lec2, 5 for lec5        */
-        struct lane2_ops *lane2_ops; /* can be NULL for LANE v1  */
-        int is_proxy;      /* bridge between ATM and Ethernet    */
-        int is_trdev;      /* Device type, 0 = Ethernet, 1 = TokenRing */
+	u8 *tlvs;				/* LANE2: TLVs are new */
+	u32 sizeoftlvs;				/* The size of the tlv array in bytes */
+	int lane_version;			/* LANE2 */
+	int itfnum;				/* e.g. 2 for lec2, 5 for lec5 */
+	struct lane2_ops *lane2_ops;		/* can be NULL for LANE v1 */
+	int is_proxy;				/* bridge between ATM and Ethernet */
+	int is_trdev;				/* Device type, 0 = Ethernet, 1 = TokenRing */
 };
 
 struct lec_vcc_priv {
-	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
+	void (*old_pop) (struct atm_vcc *vcc, struct sk_buff *skb);
 	int xoff;
 };
 
 #define LEC_VCC_PRIV(vcc)	((struct lec_vcc_priv *)((vcc)->user_back))
 
-#endif /* _LEC_H_ */
-
+#endif				/* _LEC_H_ */
diff --git a/net/atm/lec_arpc.h b/net/atm/lec_arpc.h
index 3974480..eb09a35 100644
--- a/net/atm/lec_arpc.h
+++ b/net/atm/lec_arpc.h
@@ -1,92 +1,98 @@
 /*
  * Lec arp cache
- * Marko Kiiskila mkiiskila@yahoo.com
  *
+ * Marko Kiiskila <mkiiskila@yahoo.com>
  */
-#ifndef _LEC_ARP_H
-#define _LEC_ARP_H
+#ifndef _LEC_ARP_H_
+#define _LEC_ARP_H_
 #include <linux/atm.h>
 #include <linux/atmdev.h>
 #include <linux/if_ether.h>
 #include <linux/atmlec.h>
 
 struct lec_arp_table {
-        struct lec_arp_table *next;          /* Linked entry list */
-        unsigned char atm_addr[ATM_ESA_LEN]; /* Atm address */
-        unsigned char mac_addr[ETH_ALEN];    /* Mac address */
-        int is_rdesc;                        /* Mac address is a route descriptor */
-        struct atm_vcc *vcc;                 /* Vcc this entry is attached */
-        struct atm_vcc *recv_vcc;            /* Vcc we receive data from */
-        void (*old_push)(struct atm_vcc *vcc,struct sk_buff *skb); 
-                                             /* Push that leads to daemon */
-        void (*old_recv_push)(struct atm_vcc *vcc, struct sk_buff *skb);
-                                             /* Push that leads to daemon */
-        void (*old_close)(struct atm_vcc *vcc);
-                                             /* We want to see when this
-                                              * vcc gets closed */
-        unsigned long last_used;             /* For expiry */
-        unsigned long timestamp;             /* Used for various timestamping
-                                              * things:
-                                              * 1. FLUSH started 
-                                              *    (status=ESI_FLUSH_PENDING)
-                                              * 2. Counting to 
-                                              *    max_unknown_frame_time
-                                              *    (status=ESI_ARP_PENDING||
-                                              *     status=ESI_VC_PENDING)
-                                              */
-        unsigned char no_tries;              /* No of times arp retry has been 
-                                                tried */
-        unsigned char status;                /* Status of this entry */
-        unsigned short flags;                /* Flags for this entry */
-        unsigned short packets_flooded;      /* Data packets flooded */
-        unsigned long flush_tran_id;         /* Transaction id in flush protocol */
-        struct timer_list timer;             /* Arping timer */
-        struct lec_priv *priv;               /* Pointer back */
+	struct lec_arp_table *next;	/* Linked entry list */
+	unsigned char atm_addr[ATM_ESA_LEN];	/* Atm address */
+	unsigned char mac_addr[ETH_ALEN];	/* Mac address */
+	int is_rdesc;			/* Mac address is a route descriptor */
+	struct atm_vcc *vcc;		/* Vcc this entry is attached */
+	struct atm_vcc *recv_vcc;	/* Vcc we receive data from */
 
-        u8  *tlvs;             /* LANE2: Each MAC address can have TLVs    */
-        u32 sizeoftlvs;        /* associated with it. sizeoftlvs tells the */
-                               /* the length of the tlvs array             */
-        struct sk_buff_head tx_wait; /* wait queue for outgoing packets    */
+	void (*old_push) (struct atm_vcc *vcc, struct sk_buff *skb);
+					/* Push that leads to daemon */
+
+	void (*old_recv_push) (struct atm_vcc *vcc, struct sk_buff *skb);
+					/* Push that leads to daemon */
+
+	void (*old_close) (struct atm_vcc *vcc);
+					/* We want to see when this vcc gets closed */
+
+	unsigned long last_used;	/* For expiry */
+	unsigned long timestamp;	/* Used for various timestamping things:
+					 * 1. FLUSH started 
+					 *    (status=ESI_FLUSH_PENDING)
+					 * 2. Counting to 
+					 *    max_unknown_frame_time
+					 *    (status=ESI_ARP_PENDING||
+					 *     status=ESI_VC_PENDING)
+					 */
+	unsigned char no_tries;		/* No of times arp retry has been tried */
+	unsigned char status;		/* Status of this entry */
+	unsigned short flags;		/* Flags for this entry */
+	unsigned short packets_flooded;	/* Data packets flooded */
+	unsigned long flush_tran_id;	/* Transaction id in flush protocol */
+	struct timer_list timer;	/* Arping timer */
+	struct lec_priv *priv;		/* Pointer back */
+	u8 *tlvs;
+	u32 sizeoftlvs;			/*
+					 * LANE2: Each MAC address can have TLVs
+					 * associated with it.  sizeoftlvs tells the
+					 * the length of the tlvs array
+					 */
+	struct sk_buff_head tx_wait;	/* wait queue for outgoing packets */
 };
 
-struct tlv {                   /* LANE2: Template tlv struct for accessing */
-                               /* the tlvs in the lec_arp_table->tlvs array*/
-        u32 type;
-        u8  length;
-        u8  value[255];
+/*
+ * LANE2: Template tlv struct for accessing
+ * the tlvs in the lec_arp_table->tlvs array
+ */
+struct tlv {		
+	u32 type;
+	u8 length;
+	u8 value[255];
 };
 
 /* Status fields */
-#define ESI_UNKNOWN 0       /*
-                             * Next packet sent to this mac address
-                             * causes ARP-request to be sent 
-                             */
-#define ESI_ARP_PENDING 1   /*
-                             * There is no ATM address associated with this
-                             * 48-bit address.  The LE-ARP protocol is in
-                             * progress.
-                             */
-#define ESI_VC_PENDING 2    /*
-                             * There is a valid ATM address associated with 
-                             * this 48-bit address but there is no VC set 
-                             * up to that ATM address.  The signaling 
-                             * protocol is in process.
-                             */
-#define ESI_FLUSH_PENDING 4 /*
-                             * The LEC has been notified of the FLUSH_START
-                             * status and it is assumed that the flush 
-                             * protocol is in process.
-                             */
-#define ESI_FORWARD_DIRECT 5 /*
-                              * Either the Path Switching Delay (C22) has 
-                              * elapsed or the LEC has notified the Mapping 
-                              * that the flush protocol has completed.  In 
-                              * either case, it is safe to forward packets 
-                              * to this address via the data direct VC.
-                              */
+#define ESI_UNKNOWN 0		/*
+				 * Next packet sent to this mac address
+				 * causes ARP-request to be sent 
+				 */
+#define ESI_ARP_PENDING 1	/*
+				 * There is no ATM address associated with this
+				 * 48-bit address.  The LE-ARP protocol is in
+				 * progress.
+				 */
+#define ESI_VC_PENDING 2	/*
+				 * There is a valid ATM address associated with 
+				 * this 48-bit address but there is no VC set 
+				 * up to that ATM address.  The signaling 
+				 * protocol is in process.
+				 */
+#define ESI_FLUSH_PENDING 4	/*
+				 * The LEC has been notified of the FLUSH_START
+				 * status and it is assumed that the flush 
+				 * protocol is in process.
+				 */
+#define ESI_FORWARD_DIRECT 5	/*
+				 * Either the Path Switching Delay (C22) has 
+				 * elapsed or the LEC has notified the Mapping 
+				 * that the flush protocol has completed.  In 
+				 * either case, it is safe to forward packets 
+				 * to this address via the data direct VC.
+				 */
 
 /* Flag values */
 #define LEC_REMOTE_FLAG      0x0001
 #define LEC_PERMANENT_FLAG   0x0002
 
-#endif
+#endif /* _LEC_ARP_H_ */
