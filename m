From: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: [PATCH 2/2] [v2] netdev/phy: skip disabled mdio-mux nodes
Date: Tue, 14 Aug 2012 18:20:24 -0500
Message-ID: <1344986424-14360-2-git-send-email-timur@freescale.com>
References: <1344986424-14360-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, David Miller
 <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1344986424-14360-1-git-send-email-timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

The mdio-mux driver scans all child mdio nodes, without regard to whether
the node is actually used.  Some device trees include all possible
mdio-mux nodes and rely on the boot loader to disable those that are not
present, based on some run-time configuration.  Those nodes need to be
skipped.

Signed-off-by: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
---
 drivers/net/phy/mdio-mux.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 5c12018..4d4d25e 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -132,7 +132,7 @@ int mdio_mux_init(struct device *dev,
 	pb->mii_bus = parent_bus;
 
 	ret_val = -ENODEV;
-	for_each_child_of_node(dev->of_node, child_bus_node) {
+	for_each_available_child_of_node(dev->of_node, child_bus_node) {
 		u32 v;
 
 		r = of_property_read_u32(child_bus_node, "reg", &v);
-- 
1.7.3.4
