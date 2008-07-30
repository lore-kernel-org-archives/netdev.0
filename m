From: akpm@linux-foundation.org
Subject: [patch 05/11] atm: fix const assignment/discard warnings in the ATM networking driver
Date: Wed, 30 Jul 2008 12:37:37 -0700
Message-ID: <200807301937.m6UJbbHT012437@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dhowells@redhat.com, chas@cmf.nrl.navy.mil
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52199 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754285AbYG3Tib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:38:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

Fix const assignment/discard warnings in the ATM networking driver.

The lane2_assoc_ind() function needed its arguments changing to match changes
in the lane2_ops struct (patch 61c33e012964ce358b42d2a1e9cd309af5dab02b).

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/atm/mpc.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff -puN net/atm/mpc.c~atm-fix-const-assignment-discard-warnings-in-the-atm-networking-driver net/atm/mpc.c
--- a/net/atm/mpc.c~atm-fix-const-assignment-discard-warnings-in-the-atm-networking-driver
+++ a/net/atm/mpc.c
@@ -62,11 +62,13 @@ static void MPOA_cache_impos_rcvd(struct
 static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg, struct mpoa_client *mpc);
 static void set_mps_mac_addr_rcvd(struct k_message *mesg, struct mpoa_client *mpc);
 
-static uint8_t *copy_macs(struct mpoa_client *mpc, uint8_t *router_mac,
-			  uint8_t *tlvs, uint8_t mps_macs, uint8_t device_type);
+static const uint8_t *copy_macs(struct mpoa_client *mpc,
+				const uint8_t *router_mac,
+				const uint8_t *tlvs, uint8_t mps_macs,
+				uint8_t device_type);
 static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry);
 
-static void send_set_mps_ctrl_addr(char *addr, struct mpoa_client *mpc);
+static void send_set_mps_ctrl_addr(const char *addr, struct mpoa_client *mpc);
 static void mpoad_close(struct atm_vcc *vcc);
 static int msg_from_mpoad(struct atm_vcc *vcc, struct sk_buff *skb);
 
@@ -351,12 +353,12 @@ static const char *mpoa_device_type_stri
  * lec sees a TLV it uses the pointer to call this function.
  *
  */
-static void lane2_assoc_ind(struct net_device *dev, uint8_t *mac_addr,
-			    uint8_t *tlvs, uint32_t sizeoftlvs)
+static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
+			    const u8 *tlvs, u32 sizeoftlvs)
 {
 	uint32_t type;
 	uint8_t length, mpoa_device_type, number_of_mps_macs;
-	uint8_t *end_of_tlvs;
+	const uint8_t *end_of_tlvs;
 	struct mpoa_client *mpc;
 
 	mpoa_device_type = number_of_mps_macs = 0; /* silence gcc */
@@ -430,8 +432,10 @@ static void lane2_assoc_ind(struct net_d
  * plus the possible MAC address(es) to mpc->mps_macs.
  * For a freshly allocated MPOA client mpc->mps_macs == 0.
  */
-static uint8_t *copy_macs(struct mpoa_client *mpc, uint8_t *router_mac,
-			  uint8_t *tlvs, uint8_t mps_macs, uint8_t device_type)
+static const uint8_t *copy_macs(struct mpoa_client *mpc,
+				const uint8_t *router_mac,
+				const uint8_t *tlvs, uint8_t mps_macs,
+				uint8_t device_type)
 {
 	int num_macs;
 	num_macs = (mps_macs > 1) ? mps_macs : 1;
@@ -811,7 +815,7 @@ static int atm_mpoa_mpoad_attach (struct
 	return arg;
 }
 
-static void send_set_mps_ctrl_addr(char *addr, struct mpoa_client *mpc)
+static void send_set_mps_ctrl_addr(const char *addr, struct mpoa_client *mpc)
 {
 	struct k_message mesg;
 
_
