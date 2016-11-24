From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 3/5] net: fsl/fman: fix phydev reference leak
Date: Thu, 24 Nov 2016 19:21:29 +0100
Message-ID: <1480011691-13278-4-git-send-email-johan@kernel.org>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Timur Tabi <timur@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480011691-13278-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by of_phy_find_device() during
initialisation when later freeing the struct fman_mac.

Fixes: 57ba4c9b56d8 ("fsl/fman: Add FMan MAC support")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/freescale/fman/fman_memac.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fman/fman_memac.c b/drivers/net/ethernet/freescale/fman/fman_memac.c
index 53ef51e3bd9e..71a5ded9d1de 100644
--- a/drivers/net/ethernet/freescale/fman/fman_memac.c
+++ b/drivers/net/ethernet/freescale/fman/fman_memac.c
@@ -1107,6 +1107,9 @@ int memac_free(struct fman_mac *memac)
 {
 	free_init_resources(memac);
 
+	if (memac->pcsphy)
+		put_device(&memac->pcsphy->mdio.dev);
+
 	kfree(memac->memac_drv_param);
 	kfree(memac);
 
-- 
2.7.3
