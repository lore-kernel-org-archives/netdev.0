From: Ethan Zhao <ethan.zhao@oracle.com>
Subject: [PATCH] ixgbe: remove useless bd_number from adapter
	struct
Date: Mon, 28 Jul 2014 15:41:18 +0800
Message-ID: <1406533278-27979-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.zhao@oracle.com>, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ethan.kernel@gmail.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Because bd_number is not useful anymore, so remove it from adapter struct, or
if keep it, we have to fix the boards driven counter bug in ixgbe_remove() and
ixgbe_probe() only for trival debug purpose -- other output is enough.

Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ----
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index c6c4ca7..238a74f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -752,8 +752,6 @@ struct ixgbe_adapter {
 	u8 __iomem *io_addr; /* Mainly for iounmap use */
 	u32 wol;
 
-	u16 bd_number;
-
 	u16 eeprom_verh;
 	u16 eeprom_verl;
 	u16 eeprom_cap;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d62e7a2..1e25e8e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7929,7 +7929,6 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct ixgbe_adapter *adapter = NULL;
 	struct ixgbe_hw *hw;
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
-	static int cards_found;
 	int i, err, pci_using_dac, expected_gts;
 	unsigned int indices = MAX_TX_QUEUES;
 	u8 part_str[IXGBE_PBANUM_LENGTH];
@@ -8015,8 +8014,6 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->watchdog_timeo = 5 * HZ;
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
-	adapter->bd_number = cards_found;
-
 	/* Setup hw api */
 	memcpy(&hw->mac.ops, ii->mac_ops, sizeof(hw->mac.ops));
 	hw->mac.type  = ii->mac;
@@ -8295,7 +8292,6 @@ skip_sriov:
 	ixgbe_add_sanmac_netdev(netdev);
 
 	e_dev_info("%s\n", ixgbe_default_device_descr);
-	cards_found++;
 
 #ifdef CONFIG_IXGBE_HWMON
 	if (ixgbe_sysfs_init(adapter))
-- 
1.7.1


------------------------------------------------------------------------------
Infragistics Professional
Build stunning WinForms apps today!
Reboot your WinForms applications with our WinForms controls. 
Build a bridge from your legacy apps to the future.
http://pubads.g.doubleclick.net/gampad/clk?id=153845071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
