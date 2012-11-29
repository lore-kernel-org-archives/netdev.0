From: Alexander Sverdlin <asv-uSbOeAmDUekAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] of_mdio: Honour "status=disabled" property of device
Date: Thu, 29 Nov 2012 08:45:20 +0100
Message-ID: <50B71290.2060200@sysgo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Barry.Song-kQvG35nSl+M@public.gmane.org, w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
 alexander sverdlin <alexander.sverdlin.ext-OYasijW0DpE@public.gmane.org>
To: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
 Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
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

From: Alexander Sverdlin <alexander.sverdlin-uSbOeAmDUekAvxtiuMwx3w@public.gmane.org>

of_mdio: Honour "status=disabled" property of device

Currently of_mdiobus_register() function registers all PHY devices,
independetly from their status property in device tree. According to
"ePAPR 1.1" spec, device should only be registered if there is no
"status" property, or it has "ok" (or "okay") value (see
of_device_is_available()). In case of "platform devices",
of_platform_device_create_pdata() checks for "status" and ensures
that disabled devices are not pupulated. But such check for MDIO buses
was missing until now. Fix it.

Signed-off-by: Alexander Sverdlin <alexander.sverdlin-uSbOeAmDUekAvxtiuMwx3w@public.gmane.org>
---
--- linux.orig/drivers/of/of_mdio.c
+++ linux/drivers/of/of_mdio.c
@@ -53,7 +53,7 @@ int of_mdiobus_register(struct mii_bus *
 		return rc;
 
 	/* Loop over the child nodes and register a phy_device for each one */
-	for_each_child_of_node(np, child) {
+	for_each_available_child_of_node(np, child) {
 		const __be32 *paddr;
 		u32 addr;
 		int len;
