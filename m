From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 15/50] lantiq_etop: set addr_assign_type if random_ether_addr() used
Date: Wed,  8 Feb 2012 22:10:22 +0100
Message-ID: <1328735457-29986-16-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Crispin <blogic@openwrt.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set addr_assign_type correctly to NET_ADDR_RANDOM in case
a random MAC address was generated and assigned to the netdevice.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/lantiq_etop.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 85e2c6c..b4f5108 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -634,6 +634,7 @@ ltq_etop_init(struct net_device *dev)
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 	struct sockaddr mac;
 	int err;
+	bool random = false;
 
 	ether_setup(dev);
 	dev->watchdog_timeo = 10 * HZ;
@@ -646,9 +647,12 @@ ltq_etop_init(struct net_device *dev)
 	if (!is_valid_ether_addr(mac.sa_data)) {
 		pr_warn("etop: invalid MAC, using random\n");
 		random_ether_addr(mac.sa_data);
+		random = true;
 	}
 
 	err = ltq_etop_set_mac_address(dev, &mac);
+	if (random)
+		dev->addr_assign_type |= NET_ADDR_RANDOM;
 	if (err)
 		goto err_netdev;
 	ltq_etop_set_multicast_list(dev);
-- 
1.7.7.3
