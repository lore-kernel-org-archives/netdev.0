From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] of_mdio: kill useless variable in of_phy_register_fixed_link()
Date: Sun, 23 Jul 2017 21:45:47 +0300
Message-ID: <20170723184612.321910595@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=of_mdio-kill-useless-variable-in-of_phy_register_fixed_link.patch
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

of_phy_register_fixed_link() declares the 'err' variable to hold the result
of of_property_read_string() but only uses it once after that, while that
function can be called directly from the *if* statement...

Remove that variable and move/regroup 'link_gpio' and 'len' variables in
order to sort the declarations in the reverse Xmas tree order -- to please
DaveM. ;-)

Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

---
 drivers/of/of_mdio.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

Index: linux/drivers/of/of_mdio.c
===================================================================
--- linux.orig/drivers/of/of_mdio.c
+++ linux/drivers/of/of_mdio.c
@@ -422,13 +422,11 @@ int of_phy_register_fixed_link(struct de
 	struct fixed_phy_status status = {};
 	struct device_node *fixed_link_node;
 	const __be32 *fixed_link_prop;
-	int link_gpio;
-	int len, err;
 	struct phy_device *phy;
 	const char *managed;
+	int link_gpio, len;
 
-	err = of_property_read_string(np, "managed", &managed);
-	if (err == 0) {
+	if (of_property_read_string(np, "managed", &managed) == 0) {
 		if (strcmp(managed, "in-band-status") == 0) {
 			/* status is zeroed, namely its .link member */
 			phy = fixed_phy_register(PHY_POLL, &status, -1, np);

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
