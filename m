From: Jan Engelhardt <jengelh@medozas.de>
Subject: net: mark read-only arrays as const
Date: Wed, 5 Aug 2009 17:10:36 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0908051708340.11618@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33498 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934583AbZHEPKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 11:10:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I took the freedom to just make one commit out of it, as it is
relatively simple cosmetic change.
Please consider for davem/net-next-2.6.

--->8---
parent 71cedacf9a406ab66511eb5764e4cd6b26df8c6b (v2.6.31-rc1-105-g71cedac)
commit 8728b591fc89b7913026ab1e03f370f9cf3b9c18
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Aug 5 17:07:55 2009 +0200

net: mark read-only arrays as const

String literals are constant, and usually, we can also tag the array
of pointers const too, moving it to the .rodata section.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/net/ip_vs.h                  |    3 ++-
 include/net/irda/ircomm_event.h      |    2 +-
 include/net/irda/ircomm_tty_attach.h |    4 ++--
 include/net/irda/irlap_event.h       |    2 +-
 include/net/irda/irlmp_event.h       |    4 ++--
 include/net/sctp/constants.h         |    4 +++-
 net/8021q/vlanproc.c                 |    2 +-
 net/atm/lec.c                        |    9 +++++----
 net/atm/proc.c                       |    9 +++++----
 net/bluetooth/af_bluetooth.c         |    4 ++--
 net/bridge/br_stp.c                  |    2 +-
 net/core/dev.c                       |    2 +-
 net/core/net-sysfs.c                 |    2 +-
 net/core/sock.c                      |    6 +++---
 net/dccp/ccids/ccid3.c               |    4 ++--
 net/dccp/feat.c                      |    7 ++++---
 net/dccp/proto.c                     |    4 ++--
 net/ipv4/fib_trie.c                  |    2 +-
 net/ipv6/proc.c                      |    4 ++--
 net/irda/ircomm/ircomm_event.c       |    4 ++--
 net/irda/ircomm/ircomm_tty_attach.c  |    4 ++--
 net/irda/iriap.c                     |    4 ++--
 net/irda/irlan/irlan_common.c        |    4 ++--
 net/irda/irlap.c                     |    2 +-
 net/irda/irlap_event.c               |    4 ++--
 net/irda/irlmp_event.c               |    6 +++---
 net/llc/llc_proc.c                   |    2 +-
 net/netfilter/ipvs/ip_vs_proto.c     |    3 ++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c |    2 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c |    2 +-
 net/rds/ib_stats.c                   |    2 +-
 net/rds/iw_stats.c                   |    2 +-
 net/rds/rds.h                        |    3 ++-
 net/rds/stats.c                      |    4 ++--
 net/rxrpc/ar-ack.c                   |    2 +-
 net/sctp/debug.c                     |   14 +++++++-------
 36 files changed, 74 insertions(+), 66 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index bbae1e8..a191232 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -740,7 +740,8 @@ extern void ip_vs_protocol_cleanup(void);
 extern void ip_vs_protocol_timeout_change(int flags);
 extern int *ip_vs_create_timeout_table(int *table, int size);
 extern int
-ip_vs_set_state_timeout(int *table, int num, char **names, char *name, int to);
+ip_vs_set_state_timeout(int *table, int num, const char *const *names,
+			const char *name, int to);
 extern void
 ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 			  int offset, const char *msg);
diff --git a/include/net/irda/ircomm_event.h b/include/net/irda/ircomm_event.h
index c290447..bc0c6f3 100644
--- a/include/net/irda/ircomm_event.h
+++ b/include/net/irda/ircomm_event.h
@@ -74,7 +74,7 @@ struct ircomm_info {
 	struct qos_info *qos;
 };
 
-extern char *ircomm_state[];
+extern const char *const ircomm_state[];
 
 struct ircomm_cb;   /* Forward decl. */
 
diff --git a/include/net/irda/ircomm_tty_attach.h b/include/net/irda/ircomm_tty_attach.h
index f91a569..0a63bbb 100644
--- a/include/net/irda/ircomm_tty_attach.h
+++ b/include/net/irda/ircomm_tty_attach.h
@@ -66,8 +66,8 @@ struct ircomm_tty_info {
         __u8      dlsap_sel;
 };
 
-extern char *ircomm_state[];
-extern char *ircomm_tty_state[];
+extern const char *const ircomm_state[];
+extern const char *const ircomm_tty_state[];
 
 int ircomm_tty_do_event(struct ircomm_tty_cb *self, IRCOMM_TTY_EVENT event,
 			struct sk_buff *skb, struct ircomm_tty_info *info);
diff --git a/include/net/irda/irlap_event.h b/include/net/irda/irlap_event.h
index 2ae2e11..4c90824 100644
--- a/include/net/irda/irlap_event.h
+++ b/include/net/irda/irlap_event.h
@@ -120,7 +120,7 @@ typedef enum { /* FIXME check the two first reason codes */
 	LAP_PRIMARY_CONFLICT,
 } LAP_REASON;
 
-extern const char *irlap_state[];
+extern const char *const irlap_state[];
 
 void irlap_do_event(struct irlap_cb *self, IRLAP_EVENT event, 
 		    struct sk_buff *skb, struct irlap_info *info);
diff --git a/include/net/irda/irlmp_event.h b/include/net/irda/irlmp_event.h
index e03ae4a..9e4ec17 100644
--- a/include/net/irda/irlmp_event.h
+++ b/include/net/irda/irlmp_event.h
@@ -79,8 +79,8 @@ typedef enum {
 	LM_LAP_IDLE_TIMEOUT,
 } IRLMP_EVENT;
 
-extern const char *irlmp_state[];
-extern const char *irlsap_state[];
+extern const char *const irlmp_state[];
+extern const char *const irlsap_state[];
 
 void irlmp_watchdog_timer_expired(void *data);
 void irlmp_discovery_timer_expired(void *data);
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index b05b055..8bc25f7 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -241,7 +241,9 @@ const char *sctp_tname(const sctp_subtype_t);	/* timeouts */
 const char *sctp_pname(const sctp_subtype_t);	/* primitives */
 
 /* This is a table of printable names of sctp_state_t's.  */
-extern const char *sctp_state_tbl[], *sctp_evttype_tbl[], *sctp_status_tbl[];
+extern const char *const sctp_state_tbl[];
+extern const char *const sctp_evttype_tbl[];
+extern const char *const sctp_status_tbl[];
 
 /* Maximum chunk length considering padding requirements. */
 enum { SCTP_MAX_CHUNK_LEN = ((1<<16) - sizeof(__u32)) };
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index b55a091..6262c33 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -107,7 +107,7 @@ static const struct file_operations vlandev_fops = {
  */
 
 /* Strings */
-static const char *vlan_name_type_str[VLAN_NAME_TYPE_HIGHEST] = {
+static const char *const vlan_name_type_str[VLAN_NAME_TYPE_HIGHEST] = {
     [VLAN_NAME_TYPE_RAW_PLUS_VID]        = "VLAN_NAME_TYPE_RAW_PLUS_VID",
     [VLAN_NAME_TYPE_PLUS_VID_NO_PAD]	 = "VLAN_NAME_TYPE_PLUS_VID_NO_PAD",
     [VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD] = "VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD",
diff --git a/net/atm/lec.c b/net/atm/lec.c
index ff2e594..ab2b0e9 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -935,9 +935,9 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 }
 
 #ifdef CONFIG_PROC_FS
-static char *lec_arp_get_status_string(unsigned char status)
+static const char *lec_arp_get_status_string(unsigned char status)
 {
-	static char *lec_arp_status_string[] = {
+	static const char *const lec_arp_status_string[] = {
 		"ESI_UNKNOWN       ",
 		"ESI_ARP_PENDING   ",
 		"ESI_VC_PENDING    ",
@@ -1121,7 +1121,8 @@ static void *lec_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 static int lec_seq_show(struct seq_file *seq, void *v)
 {
-	static char lec_banner[] = "Itf  MAC          ATM destination"
+	static const char lec_banner[] =
+	    "Itf  MAC          ATM destination"
 	    "                          Status            Flags "
 	    "VPI/VCI Recv VPI/VCI\n";
 
@@ -1505,7 +1506,7 @@ lec_arp_remove(struct lec_priv *priv, struct lec_arp_table *to_remove)
 }
 
 #if DEBUG_ARP_TABLE
-static char *get_status_string(unsigned char st)
+static const char *get_status_string(unsigned char st)
 {
 	switch (st) {
 	case ESI_UNKNOWN:
diff --git a/net/atm/proc.c b/net/atm/proc.c
index 38de5ff..ab8419a 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -151,8 +151,9 @@ static void *vcc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 static void pvc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
-	static const char *class_name[] = { "off","UBR","CBR","VBR","ABR" };
-	static const char *aal_name[] = {
+	static const char *const class_name[] =
+		{"off","UBR","CBR","VBR","ABR"};
+	static const char *const aal_name[] = {
 		"---",	"1",	"2",	"3/4",	/*  0- 3 */
 		"???",	"5",	"???",	"???",	/*  4- 7 */
 		"???",	"???",	"???",	"???",	/*  8-11 */
@@ -178,7 +179,7 @@ static void pvc_info(struct seq_file *seq, struct atm_vcc *vcc)
 
 static const char *vcc_state(struct atm_vcc *vcc)
 {
-	static const char *map[] = { ATM_VS2TXT_MAP };
+	static const char *const map[] = { ATM_VS2TXT_MAP };
 
 	return map[ATM_VF2VS(vcc->flags)];
 }
@@ -335,7 +336,7 @@ static const struct file_operations vcc_seq_fops = {
 
 static int svc_seq_show(struct seq_file *seq, void *v)
 {
-	static char atm_svc_banner[] =
+	static const char atm_svc_banner[] =
 		"Itf VPI VCI           State      Remote\n";
 
 	if (v == SEQ_START_TOKEN)
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 0250e06..8cfb5a8 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -49,7 +49,7 @@ static struct net_proto_family *bt_proto[BT_MAX_PROTO];
 static DEFINE_RWLOCK(bt_proto_lock);
 
 static struct lock_class_key bt_lock_key[BT_MAX_PROTO];
-static const char *bt_key_strings[BT_MAX_PROTO] = {
+static const char *const bt_key_strings[BT_MAX_PROTO] = {
 	"sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP",
 	"sk_lock-AF_BLUETOOTH-BTPROTO_HCI",
 	"sk_lock-AF_BLUETOOTH-BTPROTO_SCO",
@@ -61,7 +61,7 @@ static const char *bt_key_strings[BT_MAX_PROTO] = {
 };
 
 static struct lock_class_key bt_slock_key[BT_MAX_PROTO];
-static const char *bt_slock_key_strings[BT_MAX_PROTO] = {
+static const char *const bt_slock_key_strings[BT_MAX_PROTO] = {
 	"slock-AF_BLUETOOTH-BTPROTO_L2CAP",
 	"slock-AF_BLUETOOTH-BTPROTO_HCI",
 	"slock-AF_BLUETOOTH-BTPROTO_SCO",
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 0660515..fd3f8d6 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -21,7 +21,7 @@
  */
 #define MESSAGE_AGE_INCR	((HZ < 256) ? 1 : (HZ/256))
 
-static const char *br_port_state_names[] = {
+static const char *const br_port_state_names[] = {
 	[BR_STATE_DISABLED] = "disabled",
 	[BR_STATE_LISTENING] = "listening",
 	[BR_STATE_LEARNING] = "learning",
diff --git a/net/core/dev.c b/net/core/dev.c
index 60b5728..5864260 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -272,7 +272,7 @@ static const unsigned short netdev_lock_type[] =
 	 ARPHRD_PHONET_PIPE, ARPHRD_IEEE802154, ARPHRD_IEEE802154_PHY,
 	 ARPHRD_VOID, ARPHRD_NONE};
 
-static const char *netdev_lock_name[] =
+static const char *const netdev_lock_name[] =
 	{"_xmit_NETROM", "_xmit_ETHER", "_xmit_EETHER", "_xmit_AX25",
 	 "_xmit_PRONET", "_xmit_CHAOS", "_xmit_IEEE802", "_xmit_ARCNET",
 	 "_xmit_APPLETLK", "_xmit_DLCI", "_xmit_ATM", "_xmit_METRICOM",
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 3994680..ad91e9e 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -141,7 +141,7 @@ static ssize_t show_dormant(struct device *dev,
 	return -EINVAL;
 }
 
-static const char *operstates[] = {
+static const char *const operstates[] = {
 	"unknown",
 	"notpresent", /* currently unused */
 	"down",
diff --git a/net/core/sock.c b/net/core/sock.c
index 025317f..97ae816 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -142,7 +142,7 @@ static struct lock_class_key af_family_slock_keys[AF_MAX];
  * strings build-time, so that runtime initialization of socket
  * locks is fast):
  */
-static const char *af_family_key_strings[AF_MAX+1] = {
+static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_UNSPEC", "sk_lock-AF_UNIX"     , "sk_lock-AF_INET"     ,
   "sk_lock-AF_AX25"  , "sk_lock-AF_IPX"      , "sk_lock-AF_APPLETALK",
   "sk_lock-AF_NETROM", "sk_lock-AF_BRIDGE"   , "sk_lock-AF_ATMPVC"   ,
@@ -158,7 +158,7 @@ static const char *af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_IEEE802154",
   "sk_lock-AF_MAX"
 };
-static const char *af_family_slock_key_strings[AF_MAX+1] = {
+static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
   "slock-AF_AX25"  , "slock-AF_IPX"      , "slock-AF_APPLETALK",
   "slock-AF_NETROM", "slock-AF_BRIDGE"   , "slock-AF_ATMPVC"   ,
@@ -174,7 +174,7 @@ static const char *af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_IEEE802154",
   "slock-AF_MAX"
 };
-static const char *af_family_clock_key_strings[AF_MAX+1] = {
+static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
   "clock-AF_AX25"  , "clock-AF_IPX"      , "clock-AF_APPLETALK",
   "clock-AF_NETROM", "clock-AF_BRIDGE"   , "clock-AF_ATMPVC"   ,
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index a27b7f4..f596ce1 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -52,7 +52,7 @@ static int ccid3_debug;
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 {
-	static char *ccid3_state_names[] = {
+	static const char *const ccid3_state_names[] = {
 	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
 	[TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
 	[TFRC_SSTATE_FBACK]    = "FBACK",
@@ -646,7 +646,7 @@ enum ccid3_fback_type {
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 {
-	static char *ccid3_rx_state_names[] = {
+	static const char *const ccid3_rx_state_names[] = {
 	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
 	[TFRC_RSTATE_DATA]    = "DATA",
 	[TFRC_RSTATE_TERM]    = "TERM",
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index b04160a..972b8dc 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -213,7 +213,7 @@ static int dccp_feat_default_value(u8 feat_num)
  */
 static const char *dccp_feat_fname(const u8 feat)
 {
-	static const char *feature_names[] = {
+	static const char *const feature_names[] = {
 		[DCCPF_RESERVED]	= "Reserved",
 		[DCCPF_CCID]		= "CCID",
 		[DCCPF_SHORT_SEQNOS]	= "Allow Short Seqnos",
@@ -236,8 +236,9 @@ static const char *dccp_feat_fname(const u8 feat)
 	return feature_names[feat];
 }
 
-static const char *dccp_feat_sname[] = { "DEFAULT", "INITIALISING", "CHANGING",
-					 "UNSTABLE", "STABLE" };
+static const char *const dccp_feat_sname[] = {
+	"DEFAULT", "INITIALISING", "CHANGING", "UNSTABLE", "STABLE",
+};
 
 #ifdef CONFIG_IP_DCCP_DEBUG
 static const char *dccp_feat_oname(const u8 opt)
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 314a1b5..af65f02 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -124,7 +124,7 @@ EXPORT_SYMBOL_GPL(dccp_done);
 
 const char *dccp_packet_name(const int type)
 {
-	static const char *dccp_packet_names[] = {
+	static const char *const dccp_packet_names[] = {
 		[DCCP_PKT_REQUEST]  = "REQUEST",
 		[DCCP_PKT_RESPONSE] = "RESPONSE",
 		[DCCP_PKT_DATA]	    = "DATA",
@@ -147,7 +147,7 @@ EXPORT_SYMBOL_GPL(dccp_packet_name);
 
 const char *dccp_state_name(const int state)
 {
-	static char *dccp_state_names[] = {
+	static const char *const dccp_state_names[] = {
 	[DCCP_OPEN]		= "OPEN",
 	[DCCP_REQUESTING]	= "REQUESTING",
 	[DCCP_PARTOPEN]		= "PARTOPEN",
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 012cf5a..f9dca9d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2388,7 +2388,7 @@ static inline const char *rtn_scope(char *buf, size_t len, enum rt_scope_t s)
 	}
 }
 
-static const char *rtn_type_names[__RTN_MAX] = {
+static const char *const rtn_type_names[__RTN_MAX] = {
 	[RTN_UNSPEC] = "UNSPEC",
 	[RTN_UNICAST] = "UNICAST",
 	[RTN_LOCAL] = "LOCAL",
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 590ddef..c9605c3 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -101,7 +101,7 @@ static struct snmp_mib snmp6_icmp6_list[] = {
 };
 
 /* RFC 4293 v6 ICMPMsgStatsTable; named items for RFC 2466 compatibility */
-static char *icmp6type2name[256] = {
+static const char *const icmp6type2name[256] = {
 	[ICMPV6_DEST_UNREACH] = "DestUnreachs",
 	[ICMPV6_PKT_TOOBIG] = "PktTooBigs",
 	[ICMPV6_TIME_EXCEED] = "TimeExcds",
@@ -144,7 +144,7 @@ static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void **mib)
 	/* print by name -- deprecated items */
 	for (i = 0; i < ICMP6MSG_MIB_MAX; i++) {
 		int icmptype;
-		char *p;
+		const char *p;
 
 		icmptype = i & 0xff;
 		p = icmp6type2name[icmptype];
diff --git a/net/irda/ircomm/ircomm_event.c b/net/irda/ircomm/ircomm_event.c
index c35b3ef..d78554f 100644
--- a/net/irda/ircomm/ircomm_event.c
+++ b/net/irda/ircomm/ircomm_event.c
@@ -49,7 +49,7 @@ static int ircomm_state_waitr(struct ircomm_cb *self, IRCOMM_EVENT event,
 static int ircomm_state_conn(struct ircomm_cb *self, IRCOMM_EVENT event,
 			     struct sk_buff *skb, struct ircomm_info *info);
 
-char *ircomm_state[] = {
+const char *const ircomm_state[] = {
 	"IRCOMM_IDLE",
 	"IRCOMM_WAITI",
 	"IRCOMM_WAITR",
@@ -57,7 +57,7 @@ char *ircomm_state[] = {
 };
 
 #ifdef CONFIG_IRDA_DEBUG
-static char *ircomm_event[] = {
+static const char *const ircomm_event[] = {
 	"IRCOMM_CONNECT_REQUEST",
 	"IRCOMM_CONNECT_RESPONSE",
 	"IRCOMM_TTP_CONNECT_INDICATION",
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index 9032a1d..eafc010 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -80,7 +80,7 @@ static int ircomm_tty_state_ready(struct ircomm_tty_cb *self,
 				  struct sk_buff *skb,
 				  struct ircomm_tty_info *info);
 
-char *ircomm_tty_state[] = {
+const char *const ircomm_tty_state[] = {
 	"IRCOMM_TTY_IDLE",
 	"IRCOMM_TTY_SEARCH",
 	"IRCOMM_TTY_QUERY_PARAMETERS",
@@ -91,7 +91,7 @@ char *ircomm_tty_state[] = {
 };
 
 #ifdef CONFIG_IRDA_DEBUG
-static char *ircomm_tty_event[] = {
+static const char *const ircomm_tty_event[] = {
 	"IRCOMM_TTY_ATTACH_CABLE",
 	"IRCOMM_TTY_DETACH_CABLE",
 	"IRCOMM_TTY_DATA_REQUEST",
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 4a105dc..294e34d 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -44,7 +44,7 @@
 
 #ifdef CONFIG_IRDA_DEBUG
 /* FIXME: This one should go in irlmp.c */
-static const char *ias_charset_types[] = {
+static const char *const ias_charset_types[] = {
 	"CS_ASCII",
 	"CS_ISO_8859_1",
 	"CS_ISO_8859_2",
@@ -966,7 +966,7 @@ static void iriap_watchdog_timer_expired(void *data)
 
 #ifdef CONFIG_PROC_FS
 
-static const char *ias_value_types[] = {
+static const char *const ias_value_types[] = {
 	"IAS_MISSING",
 	"IAS_INTEGER",
 	"IAS_OCT_SEQ",
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 774d73a..6211682 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -69,14 +69,14 @@ static int eth;   /* Use "eth" or "irlan" name for devices */
 static int access = ACCESS_PEER; /* PEER, DIRECT or HOSTED */
 
 #ifdef CONFIG_PROC_FS
-static const char *irlan_access[] = {
+static const char *const irlan_access[] = {
 	"UNKNOWN",
 	"DIRECT",
 	"PEER",
 	"HOSTED"
 };
 
-static const char *irlan_media[] = {
+static const char *const irlan_media[] = {
 	"UNKNOWN",
 	"802.3",
 	"802.5"
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index e4965b7..356e65b 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -63,7 +63,7 @@ static void irlap_init_qos_capabilities(struct irlap_cb *self,
 					struct qos_info *qos_user);
 
 #ifdef CONFIG_IRDA_DEBUG
-static char *lap_reasons[] = {
+static const char *const lap_reasons[] = {
 	"ERROR, NOT USED",
 	"LAP_DISC_INDICATION",
 	"LAP_NO_RESPONSE",
diff --git a/net/irda/irlap_event.c b/net/irda/irlap_event.c
index 16c4ef0..c5c5195 100644
--- a/net/irda/irlap_event.c
+++ b/net/irda/irlap_event.c
@@ -78,7 +78,7 @@ static int irlap_state_reset_check(struct irlap_cb *, IRLAP_EVENT event,
 				   struct sk_buff *, struct irlap_info *);
 
 #ifdef CONFIG_IRDA_DEBUG
-static const char *irlap_event[] = {
+static const char *const irlap_event[] = {
 	"DISCOVERY_REQUEST",
 	"CONNECT_REQUEST",
 	"CONNECT_RESPONSE",
@@ -120,7 +120,7 @@ static const char *irlap_event[] = {
 };
 #endif	/* CONFIG_IRDA_DEBUG */
 
-const char *irlap_state[] = {
+const char *const irlap_state[] = {
 	"LAP_NDM",
 	"LAP_QUERY",
 	"LAP_REPLY",
diff --git a/net/irda/irlmp_event.c b/net/irda/irlmp_event.c
index 78cce0c..c1fb5db 100644
--- a/net/irda/irlmp_event.c
+++ b/net/irda/irlmp_event.c
@@ -33,13 +33,13 @@
 #include <net/irda/irlmp_frame.h>
 #include <net/irda/irlmp_event.h>
 
-const char *irlmp_state[] = {
+const char *const irlmp_state[] = {
 	"LAP_STANDBY",
 	"LAP_U_CONNECT",
 	"LAP_ACTIVE",
 };
 
-const char *irlsap_state[] = {
+const char *const irlsap_state[] = {
 	"LSAP_DISCONNECTED",
 	"LSAP_CONNECT",
 	"LSAP_CONNECT_PEND",
@@ -49,7 +49,7 @@ const char *irlsap_state[] = {
 };
 
 #ifdef CONFIG_IRDA_DEBUG
-static const char *irlmp_event[] = {
+static const char *const irlmp_event[] = {
 	"LM_CONNECT_REQUEST",
 	"LM_CONNECT_CONFIRM",
 	"LM_CONNECT_RESPONSE",
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index f97be47..be47ac4 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -143,7 +143,7 @@ out:
 	return 0;
 }
 
-static char *llc_conn_state_names[] = {
+static const char *const llc_conn_state_names[] = {
 	[LLC_CONN_STATE_ADM] =        "adm",
 	[LLC_CONN_STATE_SETUP] =      "setup",
 	[LLC_CONN_STATE_NORMAL] =     "normal",
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index a01520e..3ce9809 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -124,7 +124,8 @@ ip_vs_create_timeout_table(int *table, int size)
  *	Set timeout value for state specified by name
  */
 int
-ip_vs_set_state_timeout(int *table, int num, char **names, char *name, int to)
+ip_vs_set_state_timeout(int *table, int num, const char *const *names,
+			const char *name, int to)
 {
 	int i;
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8cba418..82742b3 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -374,7 +374,7 @@ static int tcp_timeouts[IP_VS_TCP_S_LAST+1] = {
 	[IP_VS_TCP_S_LAST]		=	2*HZ,
 };
 
-static char * tcp_state_name_table[IP_VS_TCP_S_LAST+1] = {
+static const char *const tcp_state_name_table[IP_VS_TCP_S_LAST+1] = {
 	[IP_VS_TCP_S_NONE]		=	"NONE",
 	[IP_VS_TCP_S_ESTABLISHED]	=	"ESTABLISHED",
 	[IP_VS_TCP_S_SYN_SENT]		=	"SYN_SENT",
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index d2930a7..b24e2f0 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -469,7 +469,7 @@ static int udp_timeouts[IP_VS_UDP_S_LAST+1] = {
 	[IP_VS_UDP_S_LAST]		=	2*HZ,
 };
 
-static char * udp_state_name_table[IP_VS_UDP_S_LAST+1] = {
+static const char *const udp_state_name_table[IP_VS_UDP_S_LAST+1] = {
 	[IP_VS_UDP_S_NORMAL]		=	"UDP",
 	[IP_VS_UDP_S_LAST]		=	"BUG!",
 };
diff --git a/net/rds/ib_stats.c b/net/rds/ib_stats.c
index 02e3e3d..8d84883 100644
--- a/net/rds/ib_stats.c
+++ b/net/rds/ib_stats.c
@@ -39,7 +39,7 @@
 
 DEFINE_PER_CPU(struct rds_ib_statistics, rds_ib_stats) ____cacheline_aligned;
 
-static char *rds_ib_stat_names[] = {
+static const char *const rds_ib_stat_names[] = {
 	"ib_connect_raced",
 	"ib_listen_closed_stale",
 	"ib_tx_cq_call",
diff --git a/net/rds/iw_stats.c b/net/rds/iw_stats.c
index ccc7e8f..d33ea79 100644
--- a/net/rds/iw_stats.c
+++ b/net/rds/iw_stats.c
@@ -39,7 +39,7 @@
 
 DEFINE_PER_CPU(struct rds_iw_statistics, rds_iw_stats) ____cacheline_aligned;
 
-static char *rds_iw_stat_names[] = {
+static const char *const rds_iw_stat_names[] = {
 	"iw_connect_raced",
 	"iw_listen_closed_stale",
 	"iw_tx_cq_call",
diff --git a/net/rds/rds.h b/net/rds/rds.h
index dbe1112..290566c 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -652,7 +652,8 @@ DECLARE_PER_CPU_SHARED_ALIGNED(struct rds_statistics, rds_stats);
 int __init rds_stats_init(void);
 void rds_stats_exit(void);
 void rds_stats_info_copy(struct rds_info_iterator *iter,
-			 uint64_t *values, char **names, size_t nr);
+			 uint64_t *values, const char *const *names,
+			 size_t nr);
 
 /* sysctl.c */
 int __init rds_sysctl_init(void);
diff --git a/net/rds/stats.c b/net/rds/stats.c
index 6371468..91d8c58 100644
--- a/net/rds/stats.c
+++ b/net/rds/stats.c
@@ -40,7 +40,7 @@ DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_statistics, rds_stats);
 
 /* :.,$s/unsigned long\>.*\<s_\(.*\);/"\1",/g */
 
-static char *rds_stat_names[] = {
+static const char *const rds_stat_names[] = {
 	"conn_reset",
 	"recv_drop_bad_checksum",
 	"recv_drop_old_seq",
@@ -77,7 +77,7 @@ static char *rds_stat_names[] = {
 };
 
 void rds_stats_info_copy(struct rds_info_iterator *iter,
-			 uint64_t *values, char **names, size_t nr)
+			 uint64_t *values, const char *const *names, size_t nr)
 {
 	struct rds_info_counter ctr;
 	size_t i;
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 3ac1672..c9f1f0a 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -20,7 +20,7 @@
 
 static unsigned rxrpc_ack_defer = 1;
 
-static const char *rxrpc_acks[] = {
+static const char *const rxrpc_acks[] = {
 	"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY", "IDL",
 	"-?-"
 };
diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index 7ff548a..bf24fa6 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -52,7 +52,7 @@ int sctp_debug_flag = 1;	/* Initially enable DEBUG */
 #endif	/* SCTP_DEBUG */
 
 /* These are printable forms of Chunk ID's from section 3.1.  */
-static const char *sctp_cid_tbl[SCTP_NUM_BASE_CHUNK_TYPES] = {
+static const char *const sctp_cid_tbl[SCTP_NUM_BASE_CHUNK_TYPES] = {
 	"DATA",
 	"INIT",
 	"INIT_ACK",
@@ -97,7 +97,7 @@ const char *sctp_cname(const sctp_subtype_t cid)
 }
 
 /* These are printable forms of the states.  */
-const char *sctp_state_tbl[SCTP_STATE_NUM_STATES] = {
+const char *const sctp_state_tbl[SCTP_STATE_NUM_STATES] = {
 	"STATE_EMPTY",
 	"STATE_CLOSED",
 	"STATE_COOKIE_WAIT",
@@ -110,7 +110,7 @@ const char *sctp_state_tbl[SCTP_STATE_NUM_STATES] = {
 };
 
 /* Events that could change the state of an association.  */
-const char *sctp_evttype_tbl[] = {
+const char *const sctp_evttype_tbl[] = {
 	"EVENT_T_unknown",
 	"EVENT_T_CHUNK",
 	"EVENT_T_TIMEOUT",
@@ -119,7 +119,7 @@ const char *sctp_evttype_tbl[] = {
 };
 
 /* Return value of a state function */
-const char *sctp_status_tbl[] = {
+const char *const sctp_status_tbl[] = {
 	"DISPOSITION_DISCARD",
 	"DISPOSITION_CONSUME",
 	"DISPOSITION_NOMEM",
@@ -132,7 +132,7 @@ const char *sctp_status_tbl[] = {
 };
 
 /* Printable forms of primitives */
-static const char *sctp_primitive_tbl[SCTP_NUM_PRIMITIVE_TYPES] = {
+static const char *const sctp_primitive_tbl[SCTP_NUM_PRIMITIVE_TYPES] = {
 	"PRIMITIVE_ASSOCIATE",
 	"PRIMITIVE_SHUTDOWN",
 	"PRIMITIVE_ABORT",
@@ -149,7 +149,7 @@ const char *sctp_pname(const sctp_subtype_t id)
 	return "unknown_primitive";
 }
 
-static const char *sctp_other_tbl[] = {
+static const char *const sctp_other_tbl[] = {
 	"NO_PENDING_TSN",
 	"ICMP_PROTO_UNREACH",
 };
@@ -162,7 +162,7 @@ const char *sctp_oname(const sctp_subtype_t id)
 	return "unknown 'other' event";
 }
 
-static const char *sctp_timer_tbl[] = {
+static const char *const sctp_timer_tbl[] = {
 	"TIMEOUT_NONE",
 	"TIMEOUT_T1_COOKIE",
 	"TIMEOUT_T1_INIT",
-- 
# Created with git-export-patch

