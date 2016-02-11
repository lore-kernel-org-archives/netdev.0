From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 5/6] net: thunderx: bgx: Add log message when setting mac address
Date: Thu, 11 Feb 2016 21:50:25 +0530
Message-ID: <1455207626-35488-6-git-send-email-sunil.kovvuri@gmail.com>
References: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com,
	Robert Richter <rrichter@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455207626-35488-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <rrichter@cavium.com>

Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 111835b..f8abdff 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -886,7 +886,8 @@ static void bgx_get_qlm_mode(struct bgx *bgx)
 
 #ifdef CONFIG_ACPI
 
-static int acpi_get_mac_address(struct acpi_device *adev, u8 *dst)
+static int acpi_get_mac_address(struct device *dev, struct acpi_device *adev,
+				u8 *dst)
 {
 	u8 mac[ETH_ALEN];
 	int ret;
@@ -897,10 +898,13 @@ static int acpi_get_mac_address(struct acpi_device *adev, u8 *dst)
 		goto out;
 
 	if (!is_valid_ether_addr(mac)) {
+		dev_err(dev, "MAC address invalid: %pM\n", mac);
 		ret = -EINVAL;
 		goto out;
 	}
 
+	dev_info(dev, "MAC address set to: %pM\n", mac);
+
 	memcpy(dst, mac, ETH_ALEN);
 out:
 	return ret;
@@ -911,14 +915,15 @@ static acpi_status bgx_acpi_register_phy(acpi_handle handle,
 					 u32 lvl, void *context, void **rv)
 {
 	struct bgx *bgx = context;
+	struct device *dev = &bgx->pdev->dev;
 	struct acpi_device *adev;
 
 	if (acpi_bus_get_device(handle, &adev))
 		goto out;
 
-	acpi_get_mac_address(adev, bgx->lmac[bgx->lmac_count].mac);
+	acpi_get_mac_address(dev, adev, bgx->lmac[bgx->lmac_count].mac);
 
-	SET_NETDEV_DEV(&bgx->lmac[bgx->lmac_count].netdev, &bgx->pdev->dev);
+	SET_NETDEV_DEV(&bgx->lmac[bgx->lmac_count].netdev, dev);
 
 	bgx->lmac[bgx->lmac_count].lmacid = bgx->lmac_count;
 out:
-- 
1.7.1
