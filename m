From: Caesar Wang <wxt@rock-chips.com>
Subject: [PATCH v2 2/9] net: arc_emac: add phy reset is optional for device tree
Date: Sun, 13 Mar 2016 17:07:35 +0800
Message-ID: <1457860062-5514-3-git-send-email-wxt@rock-chips.com>
References: <1457860062-5514-1-git-send-email-wxt@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, Caesar Wang <wxt@rock-chips.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457860062-5514-1-git-send-email-wxt@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the following property for arc_emac.

1) reset-gpios:
The phy reset-gpio is an optional property for arc emac device tree boot.
Change the binding document to match the driver code.

2) phy-reset-duration:
Different boards may require different phy reset duration. Add property
phy-reset-duration for device tree probe, so that the boards that need
a longer reset duration can specify it in their device tree.

Anyway, we can add the above property for arc emac.

Signed-off-by: Caesar Wang <wxt@rock-chips.com>
---

Changes in v2: None

 Documentation/devicetree/bindings/net/arc_emac.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/arc_emac.txt b/Documentation/devicetree/bindings/net/arc_emac.txt
index a1d71eb..8e84b52 100644
--- a/Documentation/devicetree/bindings/net/arc_emac.txt
+++ b/Documentation/devicetree/bindings/net/arc_emac.txt
@@ -7,6 +7,13 @@ Required properties:
 - max-speed: see ethernet.txt file in the same directory.
 - phy: see ethernet.txt file in the same directory.
 
+Optional properties:
+- reset-gpios : Should specify the gpio for phy reset
+- phy-reset-duration : Reset duration in milliseconds.  Should present
+  only if property "reset-gpios" is available.  Missing the property
+  will have the duration be 1 millisecond.  Numbers greater than 1000 are
+  invalid and 1 millisecond will be used instead.
+
 Clock handling:
 The clock frequency is needed to calculate and set polling period of EMAC.
 It must be provided by one of:
-- 
1.9.1
