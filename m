From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/23] igb: move global_quad_port_a from global
	into local static define
Date: Wed, 28 Oct 2009 02:48:31 -0700
Message-ID: <20091028094830.13156.99589.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:34181
	"EHLO QMTA12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751499AbZJ1JwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:52:16 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves global_quad_port_a into igb_probe as a static define
since it doesn't actually need to be global.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 62b6876..7f32211 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -179,8 +179,6 @@ static struct pci_driver igb_driver = {
 	.err_handler = &igb_err_handler
 };
 
-static int global_quad_port_a; /* global quad port a indication */
-
 MODULE_AUTHOR("Intel Corporation, <e1000-devel@lists.sourceforge.net>");
 MODULE_DESCRIPTION("Intel(R) Gigabit Ethernet Network Driver");
 MODULE_LICENSE("GPL");
@@ -252,12 +250,9 @@ static int __init igb_init_module(void)
 
 	printk(KERN_INFO "%s\n", igb_copyright);
 
-	global_quad_port_a = 0;
-
 #ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
 #endif
-
 	ret = pci_register_driver(&igb_driver);
 	return ret;
 }
@@ -1318,10 +1313,11 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	struct net_device *netdev;
 	struct igb_adapter *adapter;
 	struct e1000_hw *hw;
+	u16 eeprom_data = 0;
+	static int global_quad_port_a; /* global quad port a indication */
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
 	int err, pci_using_dac;
-	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
 

