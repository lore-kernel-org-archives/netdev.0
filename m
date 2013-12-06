From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH net v2 1/2] net/fddi: Replace local macro with PCI standard macro
Date: Fri, 6 Dec 2013 14:34:19 +0800
Message-ID: <1386311659-32168-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	<linux-kernel@vger.kernel.org>,
	Yijing Wang <wangyijing@huawei.com>,
	"Hanjun Guo" <guohanjun@huawei.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace local macro DFX_BUS_PCI() with PCI standard macro
dev_is_pci().

Acked-by: Maciej W. Rozycki <macro@linux-mips.org>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/fddi/defxx.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 0b40e1c..0344f71 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -241,12 +241,6 @@ static char version[] =
  */
 #define NEW_SKB_SIZE (PI_RCV_DATA_K_SIZE_MAX+128)
 
-#ifdef CONFIG_PCI
-#define DFX_BUS_PCI(dev) (dev->bus == &pci_bus_type)
-#else
-#define DFX_BUS_PCI(dev) 0
-#endif
-
 #ifdef CONFIG_EISA
 #define DFX_BUS_EISA(dev) (dev->bus == &eisa_bus_type)
 #else
@@ -436,7 +430,7 @@ static void dfx_port_read_long(DFX_board_t *bp, int offset, u32 *data)
 static void dfx_get_bars(struct device *bdev,
 			 resource_size_t *bar_start, resource_size_t *bar_len)
 {
-	int dfx_bus_pci = DFX_BUS_PCI(bdev);
+	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
@@ -518,7 +512,7 @@ static const struct net_device_ops dfx_netdev_ops = {
 static int dfx_register(struct device *bdev)
 {
 	static int version_disp;
-	int dfx_bus_pci = DFX_BUS_PCI(bdev);
+	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
 	const char *print_name = dev_name(bdev);
@@ -667,7 +661,7 @@ static void dfx_bus_init(struct net_device *dev)
 {
 	DFX_board_t *bp = netdev_priv(dev);
 	struct device *bdev = bp->bus_dev;
-	int dfx_bus_pci = DFX_BUS_PCI(bdev);
+	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
@@ -813,7 +807,7 @@ static void dfx_bus_uninit(struct net_device *dev)
 {
 	DFX_board_t *bp = netdev_priv(dev);
 	struct device *bdev = bp->bus_dev;
-	int dfx_bus_pci = DFX_BUS_PCI(bdev);
+	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
 	u8 val;
 
@@ -967,7 +961,7 @@ static int dfx_driver_init(struct net_device *dev, const char *print_name,
 {
 	DFX_board_t *bp = netdev_priv(dev);
 	struct device *bdev = bp->bus_dev;
-	int dfx_bus_pci = DFX_BUS_PCI(bdev);
+	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
@@ -1877,7 +1871,7 @@ static irqreturn_t dfx_interrupt(int irq, void *dev_id)
 	struct net_device *dev = dev_id;
 	DFX_board_t *bp = netdev_priv(dev);
 	struct device *bdev = bp->bus_dev;
-	int dfx_bus_pci = DFX_BUS_PCI(bdev);
+	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 
@@ -3579,7 +3573,7 @@ static void dfx_unregister(struct device *bdev)
 {
 	struct net_device *dev = dev_get_drvdata(bdev);
 	DFX_board_t *bp = netdev_priv(dev);
-	int dfx_bus_pci = DFX_BUS_PCI(bdev);
+	int dfx_bus_pci = dev_is_pci(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
 	resource_size_t bar_start = 0;		/* pointer to port */
-- 
1.7.1
