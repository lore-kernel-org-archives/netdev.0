From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/2] 8139cp/8139too: do not read into reserved registers
Date: Sat, 31 Dec 2011 17:44:33 +0800
Message-ID: <20111231094433.5433.67602.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akong@redhat.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

delay_eeprom() use long read for Cfg9346 register(offset 0x50) which may read
into the area of reserved register(offset 0x53). Use byte read instead.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/ethernet/realtek/8139cp.c  |    2 +-
 drivers/net/ethernet/realtek/8139too.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 87cff10..886e6be 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1589,7 +1589,7 @@ static int cp_set_mac_address(struct net_device *dev, void *p)
    No extra delay is needed with 33Mhz PCI, but 66Mhz may change this.
  */
 
-#define eeprom_delay()	readl(ee_addr)
+#define eeprom_delay()	readb(ee_addr)
 
 /* The EEPROM commands include the alway-set leading bit. */
 #define EE_EXTEND_CMD	(4)
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index d9c7227..a8779be 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -1122,7 +1122,7 @@ static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
    No extra delay is needed with 33Mhz PCI, but 66Mhz may change this.
  */
 
-#define eeprom_delay()	(void)RTL_R32(Cfg9346)
+#define eeprom_delay()	(void)RTL_R8(Cfg9346)
 
 /* The EEPROM commands include the alway-set leading bit. */
 #define EE_WRITE_CMD	(5)
