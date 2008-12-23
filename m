From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 10/10] 802.3ad: cleanup around lacpdu and bond_marker
Date: Tue, 23 Dec 2008 23:01:11 +0100
Message-ID: <20081223220603.062744707@jonathan.eitzenberger.org>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout-xforward.kundenserver.de ([212.227.17.5]:50664 "EHLO
	mout-xforward.kundenserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752128AbYLWWGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 17:06:09 -0500
Content-Disposition: inline; filename=bonding-3ad-remove-typedef-around-bond_marker.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the typedef around lacpdu and bond_marker.  Also turn C++
comments into C comments and some more or less pretty printing.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_3ad.h
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_3ad.h
+++ bonding-2.6/drivers/net/bonding/bond_3ad.h
@@ -105,52 +105,56 @@ typedef enum {
 
 #pragma pack(1)
 
-// Link Aggregation Control Protocol(LACP) data unit structure(43.4.2.2 in the 802.3ad standard)
-typedef struct lacpdu {
-	u8 subtype;		     // = LACP(= 0x01)
+/* Link Aggregation Control Protocol (LACP) data unit structure
+   (43.4.2.2 in the 802.3ad standard) */
+struct lacpdu {
+	u8 subtype;			/* LACP(= 0x01) */
 	u8 version_number;
-	u8 tlv_type_actor_info;	      // = actor information(type/length/value)
-	u8 actor_information_length; // = 20
+	u8 tlv_type_actor_info;		/* actor information TLV */
+	u8 actor_information_length;	/* = 20 */
 	__be16 actor_system_priority;
 	struct mac_addr actor_system;
 	__be16 actor_key;
 	__be16 actor_port_priority;
 	__be16 actor_port;
 	u8 actor_state;
-	u8 reserved_3_1[3];	     // = 0
-	u8 tlv_type_partner_info;     // = partner information
-	u8 partner_information_length;	 // = 20
+	u8 reserved_3_1[3];		/* = 0 */
+	u8 tlv_type_partner_info;	/* partner information */
+	u8 partner_information_length;	/* = 20 */
 	__be16 partner_system_priority;
 	struct mac_addr partner_system;
 	__be16 partner_key;
 	__be16 partner_port_priority;
 	__be16 partner_port;
 	u8 partner_state;
-	u8 reserved_3_2[3];	     // = 0
-	u8 tlv_type_collector_info;	  // = collector information
-	u8 collector_information_length; // = 16
+	u8 reserved_3_2[3];		 /* = 0 */
+	u8 tlv_type_collector_info;	 /* collector information */
+	u8 collector_information_length; /* = 16 */
 	__be16 collector_max_delay;
 	u8 reserved_12[12];
-	u8 tlv_type_terminator;	     // = terminator
-	u8 terminator_length;	     // = 0
-	u8 reserved_50[50];	     // = 0
-} lacpdu_t;
-
-// Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad standard)
-typedef struct bond_marker {
-	u8 subtype;		 //  = 0x02  (marker PDU)
-	u8 version_number;	 //  = 0x01
-	u8 tlv_type;		 //  = 0x01  (marker information)
-	//  = 0x02  (marker response information)
-	u8 marker_length;	 //  = 0x16
-	u16 requester_port;	 //   The number assigned to the port by the requester
-	struct mac_addr requester_system;      //   The requester's system id
-	u32 requester_transaction_id;	//   The transaction id allocated by the requester,
-	u16 pad;		 //  = 0
-	u8 tlv_type_terminator;	     //  = 0x00
-	u8 terminator_length;	     //  = 0x00
-	u8 reserved_90[90];	     //  = 0
-} bond_marker_t;
+	u8 tlv_type_terminator;		/* terminator */
+	u8 terminator_length;		/* = 0 */
+	u8 reserved_50[50];		/* = 0 */
+};
+
+/* Marker Protocol Data Unit (PDU) structure (43.5.3.2 in the 802.3ad
+   standard) */
+struct bond_marker {
+	u8 subtype;			/* = 0x02 (marker PDU) */
+	u8 version_number;		/* = 0x01 */
+	u8 tlv_type;			/* 0x01: marker info,
+					   0x02: marker response info */
+	u8 marker_length;		/* = 0x16 */
+	u16 requester_port;		/* number assigned to the port
+					   requester */
+	struct mac_addr requester_system; /* he requester's system id */
+	u32 requester_transaction_id;	/* transaction id allocated by
+					   requester */
+	u16 pad;			/* = 00 */
+	u8 tlv_type_terminator;		/* = 0x00 */
+	u8 terminator_length;		/* = 0x00 */
+	u8 reserved_90[90];		/* = 0 */
+};
 
 #pragma pack()
 

-- 
