From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 8/10] Staging: slicoss: convert to netdev_ops
Date: Sun, 29 Mar 2009 19:30:08 +0400
Message-ID: <20090329153008.GH11056@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758746AbZC2Pad@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/staging/slicoss/slicoss.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 953684f..22343fc 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -345,6 +345,19 @@ static void slic_init_adapter(struct net_device *netdev,
 	return;
 }
 
+static const struct net_device_ops slic_netdev_ops = {
+	.ndo_open		= slic_entry_open,
+	.ndo_stop		= slic_entry_halt,
+	.ndo_start_xmit		= slic_xmit_start,
+	.ndo_do_ioctl		= slic_ioctl,
+	.ndo_set_mac_address	= slic_mac_set_address,
+	.ndo_get_stats		= slic_get_stats,
+	.ndo_set_multicast_list	= slic_mcast_set_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 static int __devinit slic_entry_probe(struct pci_dev *pcidev,
 			       const struct pci_device_id *pci_tbl_entry)
 {
@@ -442,13 +455,7 @@ static int __devinit slic_entry_probe(struct pci_dev *pcidev,
 
 	netdev->base_addr = (unsigned long)adapter->memorybase;
 	netdev->irq = adapter->irq;
-	netdev->open = slic_entry_open;
-	netdev->stop = slic_entry_halt;
-	netdev->hard_start_xmit = slic_xmit_start;
-	netdev->do_ioctl = slic_ioctl;
-	netdev->set_mac_address = slic_mac_set_address;
-	netdev->get_stats = slic_get_stats;
-	netdev->set_multicast_list = slic_mcast_set_list;
+	netdev->netdev_ops = &slic_netdev_ops;
 
 	slic_debug_adapter_create(adapter);
 
