From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: [PATCH v1] bonding,llc: Fix structure sizeof incompatibility for some PDUs
Date: Fri, 13 May 2011 12:04:29 +0300
Message-ID: <201105131204.29612.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Joe Perches <joe@perches.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:43471 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932380Ab1EMJFC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2011 05:05:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With some combinations of arch/compiler (e.g. arm-linux-gcc) the sizeof 
operator on structure returns value greater than expected. In cases when the 
structure is used for mapping PDU fields it may lead to unexpected results 
(such as holes and alignment problems in skb data). __packed prevents this 
undesired behavior.

Signed-off-by: Vitalii Demianets <vitas@nppfactor.kiev.ua>
---
v1: use __packed macro instead of __attribute__((packed))

---
 drivers/net/bonding/bond_3ad.h |   10 +++++-----
 include/net/llc_pdu.h          |    8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 291dbd4..0ee3f16 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -39,7 +39,7 @@
 
 typedef struct mac_addr {
 	u8 mac_addr_value[ETH_ALEN];
-} mac_addr_t;
+} __packed mac_addr_t;
 
 enum {
 	BOND_AD_STABLE = 0,
@@ -134,12 +134,12 @@ typedef struct lacpdu {
 	u8 tlv_type_terminator;	     // = terminator
 	u8 terminator_length;	     // = 0
 	u8 reserved_50[50];	     // = 0
-} lacpdu_t;
+} __packed lacpdu_t;
 
 typedef struct lacpdu_header {
 	struct ethhdr hdr;
 	struct lacpdu lacpdu;
-} lacpdu_header_t;
+} __packed lacpdu_header_t;
 
 // Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad standard)
 typedef struct bond_marker {
@@ -155,12 +155,12 @@ typedef struct bond_marker {
 	u8 tlv_type_terminator;	     //  = 0x00
 	u8 terminator_length;	     //  = 0x00
 	u8 reserved_90[90];	     //  = 0
-} bond_marker_t;
+} __packed bond_marker_t;
 
 typedef struct bond_marker_header {
 	struct ethhdr hdr;
 	struct bond_marker marker;
-} bond_marker_header_t;
+} __packed bond_marker_header_t;
 
 #pragma pack()
 
diff --git a/include/net/llc_pdu.h b/include/net/llc_pdu.h
index 75b8e29..f57e7d4 100644
--- a/include/net/llc_pdu.h
+++ b/include/net/llc_pdu.h
@@ -199,7 +199,7 @@ struct llc_pdu_sn {
 	u8 ssap;
 	u8 ctrl_1;
 	u8 ctrl_2;
-};
+} __packed;
 
 static inline struct llc_pdu_sn *llc_pdu_sn_hdr(struct sk_buff *skb)
 {
@@ -211,7 +211,7 @@ struct llc_pdu_un {
 	u8 dsap;
 	u8 ssap;
 	u8 ctrl_1;
-};
+} __packed;
 
 static inline struct llc_pdu_un *llc_pdu_un_hdr(struct sk_buff *skb)
 {
@@ -359,7 +359,7 @@ struct llc_xid_info {
 	u8 fmt_id;	/* always 0x81 for LLC */
 	u8 type;	/* different if NULL/non-NULL LSAP */
 	u8 rw;		/* sender receive window */
-};
+} __packed;
 
 /**
  *	llc_pdu_init_as_xid_cmd - sets bytes 3, 4 & 5 of LLC header as XID
@@ -415,7 +415,7 @@ struct llc_frmr_info {
 	u8  curr_ssv;		/* current send state variable val */
 	u8  curr_rsv;		/* current receive state variable */
 	u8  ind_bits;		/* indicator bits set with macro */
-};
+} __packed;
 
 extern void llc_pdu_set_cmd_rsp(struct sk_buff *skb, u8 type);
 extern void llc_pdu_set_pf_bit(struct sk_buff *skb, u8 bit_value);
-- 
1.7.3.4

