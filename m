From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 6/16] e1000: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:55 -0400
Message-ID: <09122005104855.32092@bilbo.tuxdriver.com>
References: <09122005104855.32029@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	cramerj@intel.com, jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751362AbVILO65@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104855.32029@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to e1000.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/e1000/e1000_ethtool.c |    1 +
 drivers/net/e1000/e1000_main.c    |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1739,6 +1739,7 @@ struct ethtool_ops e1000_ethtool_ops = {
 	.phys_id                = e1000_phys_id,
 	.get_stats_count        = e1000_get_stats_count,
 	.get_ethtool_stats      = e1000_get_ethtool_stats,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
 void e1000_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -614,8 +614,9 @@ e1000_probe(struct pci_dev *pdev,
 	if(e1000_read_mac_addr(&adapter->hw))
 		DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
+	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
 
-	if(!is_valid_ether_addr(netdev->dev_addr)) {
+	if(!is_valid_ether_addr(netdev->perm_addr)) {
 		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
