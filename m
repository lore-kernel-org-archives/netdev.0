From: Ivan Mikhaylov <ivan-JgLE2wv1ufrQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] emac: add missing support of 10mbit in emac/rgmii
Date: Mon, 26 May 2014 22:24:17 +0400
Message-ID: <1401128657.24099.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alistair Popple <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In chips of emac/rgmii b'000' for 0/1 channel isn't suitable which
resulted in non working network interface in this mode.

Signed-off-by: Ivan Mikhaylov <ivan-JgLE2wv1ufrQT0dZR+AlfA@public.gmane.org>

---
 drivers/net/ethernet/ibm/emac/rgmii.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ibm/emac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
index 4fb2f96..a01182c 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.c
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c
@@ -45,6 +45,7 @@
 
 /* RGMIIx_SSR */
 #define RGMII_SSR_MASK(idx)	(0x7 << ((idx) * 8))
+#define RGMII_SSR_10(idx)	(0x1 << ((idx) * 8))
 #define RGMII_SSR_100(idx)	(0x2 << ((idx) * 8))
 #define RGMII_SSR_1000(idx)	(0x4 << ((idx) * 8))
 
@@ -139,6 +140,8 @@ void rgmii_set_speed(struct platform_device *ofdev, int input, int speed)
 		ssr |= RGMII_SSR_1000(input);
 	else if (speed == SPEED_100)
 		ssr |= RGMII_SSR_100(input);
+	else if (speed == SPEED_10)
+		ssr |= RGMII_SSR_10(input);
 
 	out_be32(&p->ssr, ssr);
 
-- 
1.9.3



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
