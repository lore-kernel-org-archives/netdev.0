From: Anatolij Gustschin <agust-ynQEQJNshbs@public.gmane.org>
Subject: [PATCH] of/net: fs_enet/mii-bitbang.c: fix build breakage
Date: Thu,  3 Jun 2010 03:06:54 +0200
Message-ID: <1275527214-1000-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Fixes build error caused by the OF device_node
pointer being moved into struct device

Signed-off-by: Anatolij Gustschin <agust-ynQEQJNshbs@public.gmane.org>
---
 drivers/net/fs_enet/mii-bitbang.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 0f90685..3607340 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -169,7 +169,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 
 	new_bus->name = "CPM2 Bitbanged MII",
 
-	ret = fs_mii_bitbang_init(new_bus, ofdev->node);
+	ret = fs_mii_bitbang_init(new_bus, ofdev->dev.of_node);
 	if (ret)
 		goto out_free_bus;
 
@@ -181,7 +181,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 	new_bus->parent = &ofdev->dev;
 	dev_set_drvdata(&ofdev->dev, new_bus);
 
-	ret = of_mdiobus_register(new_bus, ofdev->node);
+	ret = of_mdiobus_register(new_bus, ofdev->dev.of_node);
 	if (ret)
 		goto out_free_irqs;
 
-- 
1.7.0.4
