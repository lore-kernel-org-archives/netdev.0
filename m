From: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2] net: mediatek: update the IRQ part of the binding document
Date: Thu,  7 Apr 2016 21:28:33 +0200
Message-ID: <1460057313-55885-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Sean=20Wang=20=28=E7=8E=8B=E5=BF=97=E4=BA=98=29?=
 <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The current binding document only describes a single interrupt. Update the
document by adding the 2 other interrupts.

The driver currently only uses a single interrupt. The HW is however able
to using IRQ grouping to split TX and RX onto separate GIC irqs.

Signed-off-by: John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
Changes in V2:
* split this patch out of the series that fixes tx stalls in the driver

 Documentation/devicetree/bindings/net/mediatek-net.txt |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index 5ca7929..2f142be 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -9,7 +9,7 @@ have dual GMAC each represented by a child node..
 Required properties:
 - compatible: Should be "mediatek,mt7623-eth"
 - reg: Address and length of the register set for the device
-- interrupts: Should contain the frame engines interrupt
+- interrupts: Should contain the three frame engines interrupts
 - clocks: the clock used by the core
 - clock-names: the names of the clock listed in the clocks property. These are
 	"ethif", "esw", "gp2", "gp1"
@@ -42,7 +42,9 @@ eth: ethernet@1b100000 {
 		 <&ethsys CLK_ETHSYS_GP2>,
 		 <&ethsys CLK_ETHSYS_GP1>;
 	clock-names = "ethif", "esw", "gp2", "gp1";
-	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW>;
+	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW
+		      GIC_SPI 199 IRQ_TYPE_LEVEL_LOW
+		      GIC_SPI 198 IRQ_TYPE_LEVEL_LOW>;
 	power-domains = <&scpsys MT2701_POWER_DOMAIN_ETH>;
 	resets = <&ethsys MT2701_ETHSYS_ETH_RST>;
 	reset-names = "eth";
-- 
1.7.10.4
