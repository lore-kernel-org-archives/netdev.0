From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 5/5] ucc_geth: Convert ENET_NUM_OCTETS_PER_ADDRESS uses to ETH_ALEN
Date: Wed, 16 Nov 2011 11:38:06 -0800
Message-ID: <331ac47a2801525084ebc2b522640659dd4bbfcf.1321472143.git.joe@perches.com>
References: <cover.1321472142.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38460 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752199Ab1KPTj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 14:39:26 -0500
In-Reply-To: <cover.1321472142.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the number of #defines, use the normal #define from if_ether.h

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c |    2 +-
 drivers/net/ethernet/freescale/ucc_geth.h |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index b5dc027..ba2dc08 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -443,7 +443,7 @@ static void hw_add_addr_in_hash(struct ucc_geth_private *ugeth,
 
 static inline int compare_addr(u8 **addr1, u8 **addr2)
 {
-	return memcmp(addr1, addr2, ENET_NUM_OCTETS_PER_ADDRESS);
+	return memcmp(addr1, addr2, ETH_ALEN);
 }
 
 #ifdef DEBUG
diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
index d12fcad..2e395a2 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.h
+++ b/drivers/net/ethernet/freescale/ucc_geth.h
@@ -20,6 +20,7 @@
 
 #include <linux/kernel.h>
 #include <linux/list.h>
+#include <linux/if_ether.h>
 
 #include <asm/immap_qe.h>
 #include <asm/qe.h>
@@ -881,7 +882,6 @@ struct ucc_geth_hardware_statistics {
 #define TX_RING_MOD_MASK(size)                  (size-1)
 #define RX_RING_MOD_MASK(size)                  (size-1)
 
-#define ENET_NUM_OCTETS_PER_ADDRESS             6
 #define ENET_GROUP_ADDR                         0x01	/* Group address mask
 							   for ethernet
 							   addresses */
@@ -1051,7 +1051,7 @@ enum ucc_geth_num_of_station_addresses {
 
 /* UCC GETH 82xx Ethernet Address Container */
 struct enet_addr_container {
-	u8 address[ENET_NUM_OCTETS_PER_ADDRESS];	/* ethernet address */
+	u8 address[ETH_ALEN];	/* ethernet address */
 	enum ucc_geth_enet_address_recognition_location location;	/* location in
 								   82xx address
 								   recognition
@@ -1194,7 +1194,7 @@ struct ucc_geth_private {
 	u16 cpucount[NUM_TX_QUEUES];
 	u16 __iomem *p_cpucount[NUM_TX_QUEUES];
 	int indAddrRegUsed[NUM_OF_PADDRS];
-	u8 paddr[NUM_OF_PADDRS][ENET_NUM_OCTETS_PER_ADDRESS];	/* ethernet address */
+	u8 paddr[NUM_OF_PADDRS][ETH_ALEN];	/* ethernet address */
 	u8 numGroupAddrInHash;
 	u8 numIndAddrInHash;
 	u8 numIndAddrInReg;
-- 
1.7.6.405.gc1be0
