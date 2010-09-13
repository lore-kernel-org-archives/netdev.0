From: Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 1/9] net: davinci_emac: allow forced 100/full via phy_id
Date: Mon, 13 Sep 2010 14:07:23 -0400
Message-ID: <1284401251-8846-2-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
        linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1284401251-8846-1-git-send-email-cyril-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

With this patch, phy_id can be one of the following:
  1) NULL		: use the first phy on the bus,
  2) ""			: force to 100/full, no mdio control
  3) "<bus>:<addr>"	: use the specified bus and phy

The ability to force 100/full is necessary on some platforms (e.g. da830 evm),
where an on-board switch may be connected on the emac mii.

Signed-off-by: Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>
Signed-off-by: Michael Williamson <michael.williamson-wZX4cNJlHJ2sVWG7oymsAA@public.gmane.org>
Signed-off-by: Caglar Akyuz <caglarakyuz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/davinci_emac.c   |    2 +-
 include/linux/davinci_emac.h |    7 +++++++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 525b84c..363c970 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1566,7 +1566,7 @@ static int emac_dev_open(struct net_device *ndev)
 			priv->phy_id = dev_name(phy);
 	}
 
-	if (priv->phy_id) {
+	if (priv->phy_id && *priv->phy_id) {
 		priv->phydev = phy_connect(ndev, priv->phy_id,
 					   &emac_adjust_link, 0,
 					   PHY_INTERFACE_MODE_MII);
diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
index 7508e49..9ae9ff0 100644
--- a/include/linux/davinci_emac.h
+++ b/include/linux/davinci_emac.h
@@ -25,6 +25,13 @@ struct emac_platform_data {
 	u32 ctrl_ram_offset;
 	u32 hw_ram_addr;
 	u32 ctrl_ram_size;
+
+	/*
+	 * phy_id can be one of the following:
+	 *   - NULL		: use the first phy on the bus,
+	 *   - ""		: force to 100/full, no mdio control
+	 *   - "<bus>:<addr>"	: use the specified bus and phy
+	 */
 	const char *phy_id;
 	u8 rmii_en;
 	u8 version;
-- 
1.7.0.4
