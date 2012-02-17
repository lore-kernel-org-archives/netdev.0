From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 02/10] lantiq_etop: set addr_assign_type if random_ether_addr() used
Date: Fri, 17 Feb 2012 16:43:23 +0100
Message-ID: <1329493411-25750-3-git-send-email-danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	John Crispin <blogic@openwrt.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set addr_assign_type correctly to NET_ADDR_RANDOM in case
a random MAC address was generated and assigned to the netdevice.

v2: added comment, renamed bool variable to random_mac

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/lantiq_etop.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 85e2c6c..aee87fc 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -634,6 +634,7 @@ ltq_etop_init(struct net_device *dev)
 	struct ltq_etop_priv *priv = netdev_priv(dev);
 	struct sockaddr mac;
 	int err;
+	bool random_mac = false;
 
 	ether_setup(dev);
 	dev->watchdog_timeo = 10 * HZ;
@@ -646,11 +647,17 @@ ltq_etop_init(struct net_device *dev)
 	if (!is_valid_ether_addr(mac.sa_data)) {
 		pr_warn("etop: invalid MAC, using random\n");
 		random_ether_addr(mac.sa_data);
+		random_mac = true;
 	}
 
 	err = ltq_etop_set_mac_address(dev, &mac);
 	if (err)
 		goto err_netdev;
+
+	/*set addr_assign_type here, ltq_etop_set_mac_address would reset it*/
+	if (random_mac)
+		dev->addr_assign_type |= NET_ADDR_RANDOM;
+
 	ltq_etop_set_multicast_list(dev);
 	err = ltq_etop_mdio_init(dev);
 	if (err)
-- 
1.7.8.3
