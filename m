From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Mon, 24 Apr 2017 21:27:15 +0200
Message-ID: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sascha Weisenberger <sascha.weisenberger@siemens.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IOT2000 is industrial controller platform, derived from the Intel
Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
IOT2040 has two of them. They can be told apart based on the board asset
tag in the DMI table.

Based on patch by Sascha Weisenberger.

Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
Signed-off-by: Sascha Weisenberger <sascha.weisenberger@siemens.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 5c9e462276b9..de87c329fb5c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -32,6 +32,7 @@
  */
 struct stmmac_pci_dmi_data {
 	const char *name;
+	const char *asset_tag;
 	unsigned int func;
 	int phy_addr;
 };
@@ -46,6 +47,7 @@ struct stmmac_pci_info {
 static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
 {
 	const char *name = dmi_get_system_info(DMI_BOARD_NAME);
+	const char *asset_tag = dmi_get_system_info(DMI_BOARD_ASSET_TAG);
 	unsigned int func = PCI_FUNC(info->pdev->devfn);
 	struct stmmac_pci_dmi_data *dmi;
 
@@ -57,7 +59,8 @@ static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
 		return 1;
 
 	for (dmi = info->dmi; dmi->name && *dmi->name; dmi++) {
-		if (!strcmp(dmi->name, name) && dmi->func == func)
+		if (dmi->func == func && !strcmp(dmi->name, name) &&
+		    (!dmi->asset_tag || !strcmp(dmi->asset_tag, asset_tag)))
 			return dmi->phy_addr;
 	}
 
@@ -142,6 +145,24 @@ static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
 		.func = 6,
 		.phy_addr = 1,
 	},
+	{
+		.name = "SIMATIC IOT2000",
+		.asset_tag = "6ES7647-0AA00-0YA2",
+		.func = 6,
+		.phy_addr = 1,
+	},
+	{
+		.name = "SIMATIC IOT2000",
+		.asset_tag = "6ES7647-0AA00-1YA2",
+		.func = 6,
+		.phy_addr = 1,
+	},
+	{
+		.name = "SIMATIC IOT2000",
+		.asset_tag = "6ES7647-0AA00-1YA2",
+		.func = 7,
+		.phy_addr = 1,
+	},
 	{}
 };
 
