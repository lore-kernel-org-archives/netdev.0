From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Fix const assignment/discard warnings in the ATM networking
	driver
Date: Tue, 08 Jul 2008 18:04:54 +0100
Message-ID: <20080708170452.8406.47939.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
To: mitch@sfgoth.com, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758805AbYGHRFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 13:05:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix const assignment/discard warnings in the ATM networking driver.

The lane2_assoc_ind() function needed its arguments changing to match changes
in the lane2_ops struct (patch 61c33e012964ce358b42d2a1e9cd309af5dab02b).
---

 net/atm/mpc.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)


diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 9db332e..a122394 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -62,11 +62,13 @@ static void MPOA_cache_impos_rcvd(struct k_message *msg, struct mpoa_client *mpc
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
 
@@ -351,12 +353,12 @@ static const char *mpoa_device_type_string(char type)
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
@@ -430,8 +432,10 @@ static void lane2_assoc_ind(struct net_device *dev, uint8_t *mac_addr,
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
@@ -811,7 +815,7 @@ static int atm_mpoa_mpoad_attach (struct atm_vcc *vcc, int arg)
 	return arg;
 }
 
-static void send_set_mps_ctrl_addr(char *addr, struct mpoa_client *mpc)
+static void send_set_mps_ctrl_addr(const char *addr, struct mpoa_client *mpc)
 {
 	struct k_message mesg;
 

