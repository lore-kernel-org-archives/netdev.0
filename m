From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v3 2/9] net: arc_emac: add phy reset is optional for device
 tree
Date: Mon, 14 Mar 2016 16:01:53 +0800
Message-ID: <1457942520-12859-3-git-send-email-wxt@rock-chips.com>
References: <1457942520-12859-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>, sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
 Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, leozwang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1457942520-12859-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the following property for arc_emac.

1) phy-reset-gpios:
The phy-reset-gpio is an optional property for arc emac device tree boot.
Change the binding document to match the driver code.

2) phy-reset-duration:
Different boards may require different phy reset duration. Add property
phy-reset-duration for device tree probe, so that the boards that need
a longer reset duration can specify it in their device tree.

Anyway, we can add the above property for arc emac.

Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Cc; Alexander Kochetkov <al.kochet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---

Changes in v3:
- As Sergei comments, the original name is better, so
  %s/reset-gpios/phy-reset-gpios
- Add the Cc people.

Changes in v2:
- %s/phy-reset-gpios/reset-gpios

 Documentation/devicetree/bindings/net/arc_emac.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/arc_emac.txt b/Documentation/devicetree/bindings/net/arc_emac.txt
index a1d71eb..c73a0e9 100644
--- a/Documentation/devicetree/bindings/net/arc_emac.txt
+++ b/Documentation/devicetree/bindings/net/arc_emac.txt
@@ -7,6 +7,13 @@ Required properties:
 - max-speed: see ethernet.txt file in the same directory.
 - phy: see ethernet.txt file in the same directory.
 
+Optional properties:
+- phy-reset-gpios : Should specify the gpio for phy reset
+- phy-reset-duration : Reset duration in milliseconds.  Should present
+  only if property "phy-reset-gpios" is available.  Missing the property
+  will have the duration be 1 millisecond.  Numbers greater than 1000 are
+  invalid and 1 millisecond will be used instead.
+
 Clock handling:
 The clock frequency is needed to calculate and set polling period of EMAC.
 It must be provided by one of:
-- 
1.9.1
