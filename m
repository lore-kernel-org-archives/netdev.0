From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 22/26] igb: remove redundant count set and err_hw_init
Date: Sat, 07 Feb 2009 01:22:11 -0800
Message-ID: <20090207092211.15697.8424.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:50528
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751980AbZBGJWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:22:32 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Remove the setting of ring->count variables from igb_probe as they are
duplicating the same configuration that is done igb_alloc_queues.

Remove the err_hw_init tag as it can be replaced by err_sw_init.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d27e502..3b79ad8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1016,7 +1016,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	struct pci_dev *us_dev;
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
-	int i, err, pci_using_dac, pos;
+	int err, pci_using_dac, pos;
 	u16 eeprom_data = 0, state = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
@@ -1128,8 +1128,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	/* Initialize skew-specific constants */
 	err = ei->get_invariants(hw);
 	if (err)
-		goto err_hw_init;
+		goto err_sw_init;
 
+	/* setup the private structure */
 	err = igb_sw_init(adapter);
 	if (err)
 		goto err_sw_init;
@@ -1219,14 +1220,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->reset_task, igb_reset_task);
 	INIT_WORK(&adapter->watchdog_task, igb_watchdog_task);
 
-	/* Initialize link & ring properties that are user-changeable */
-	adapter->tx_ring->count = 256;
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		adapter->tx_ring[i].count = adapter->tx_ring->count;
-	adapter->rx_ring->count = 256;
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		adapter->rx_ring[i].count = adapter->rx_ring->count;
-
+	/* Initialize link properties that are user-changeable */
 	adapter->fc_autoneg = true;
 	hw->mac.autoneg = true;
 	hw->phy.autoneg_advertised = 0x2f;
@@ -1334,7 +1328,6 @@ err_eeprom:
 
 	igb_free_queues(adapter);
 err_sw_init:
-err_hw_init:
 	iounmap(hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);

