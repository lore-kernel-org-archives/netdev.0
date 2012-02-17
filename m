From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v3] cisco/enic: use eth_hw_addr_random() instead of random_ether_addr()
Date: Fri, 17 Feb 2012 23:13:30 +0100
Message-ID: <1329516810-26175-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Roopa Prabhu <roprabhu@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	David Wang <dwang2@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christian Benvenuti <benve@cisco.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

v3: adapt to net-next
v2: use bitops, adapt to eth_hw_addr_random(), add a comment

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index dd7e24b..7dfa567 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -865,6 +865,7 @@ static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 	}
 
 	memcpy(netdev->dev_addr, addr, netdev->addr_len);
+	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	return 0;
 }
@@ -1119,7 +1120,7 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 		memcpy(pp->mac_addr, prev_pp.vf_mac, ETH_ALEN);
 
 	if (vf == PORT_SELF_VF && is_zero_ether_addr(netdev->dev_addr))
-		random_ether_addr(netdev->dev_addr);
+		eth_hw_addr_random(netdev);
 
 	err = enic_process_set_pp_request(enic, vf, &prev_pp, &restore_pp);
 	if (err) {
-- 
1.7.8.3
