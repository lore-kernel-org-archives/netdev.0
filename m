From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next] net: Define eth_stp_addr in linux/etherdevice.h
Date: Thu,  2 Nov 2017 10:36:48 +0100
Message-ID: <20171102093648.4141-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, rafal@milecki.pl, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Why:
The lan9303 driver defines eth_stp_addr as a synonym to
eth_reserved_addr_base to get the STP ethernet address 01:80:c2:00:00:00.

eth_reserved_addr_base is also used to define the start of Bridge Reserved
ethernet address range, which happen to be the STP address.

br_dev_setup refer to eth_reserved_addr_base as a definition of STP
address.

Clean up by:
 - Move the eth_stp_addr definition to linux/etherdevice.h
 - Use eth_stp_addr instead of eth_reserved_addr_base in br_dev_setup.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 include/linux/dsa/lan9303.h | 2 --
 include/linux/etherdevice.h | 1 +
 net/bridge/br_device.c      | 2 +-
 3 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/dsa/lan9303.h b/include/linux/dsa/lan9303.h
index b2110e69630f..05d8d136baab 100644
--- a/include/linux/dsa/lan9303.h
+++ b/include/linux/dsa/lan9303.h
@@ -34,5 +34,3 @@ struct lan9303 {
 	 **/
 	struct lan9303_alr_cache_entry alr_cache[LAN9303_NUM_ALR_RECORDS];
 };
-
-#define eth_stp_addr eth_reserved_addr_base
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 2d9f80848d4b..263dbcad22fc 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -66,6 +66,7 @@ int eth_gro_complete(struct sk_buff *skb, int nhoff);
 /* Reserved Ethernet Addresses per IEEE 802.1Q */
 static const u8 eth_reserved_addr_base[ETH_ALEN] __aligned(2) =
 { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
+#define eth_stp_addr eth_reserved_addr_base
 
 /**
  * is_link_local_ether_addr - Determine if given Ethernet address is link-local
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 28bb22186fa0..af5b8c87f590 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -421,7 +421,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_id.prio[0] = 0x80;
 	br->bridge_id.prio[1] = 0x00;
 
-	ether_addr_copy(br->group_addr, eth_reserved_addr_base);
+	ether_addr_copy(br->group_addr, eth_stp_addr);
 
 	br->stp_enabled = BR_NO_STP;
 	br->group_fwd_mask = BR_GROUPFWD_DEFAULT;
-- 
2.11.0
