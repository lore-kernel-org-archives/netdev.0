From: Domen Puncer <domen.puncer@telargo.com>
Subject: [PATCH v3 1/4] FEC mpc52xx: device tree changes
Date: Sun, 14 Oct 2007 09:57:11 +0200
Message-ID: <20071014075711.GD3000@nd47.coderock.org>
References: <20071014075511.GC3000@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: galak@kernel.crashing.org, jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20071014075511.GC3000@nd47.coderock.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Add device tree entries for lite5200b's FEC's PHY.


Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

---
 arch/powerpc/boot/dts/lite5200b.dts |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletion(-)

Index: linux.git/arch/powerpc/boot/dts/lite5200b.dts
===================================================================
--- linux.git.orig/arch/powerpc/boot/dts/lite5200b.dts
+++ linux.git/arch/powerpc/boot/dts/lite5200b.dts
@@ -277,10 +277,26 @@
 		ethernet@3000 {
 			device_type = "network";
 			compatible = "mpc5200b-fec","mpc5200-fec";
-			reg = <3000 800>;
+			reg = <3000 400>;
 			mac-address = [ 02 03 04 05 06 07 ]; // Bad!
 			interrupts = <2 5 0>;
 			interrupt-parent = <&mpc5200_pic>;
+			phy-handle = <&phy0>;
+		};
+
+		mdio@3000 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			device_type = "mdio";
+			compatible = "mpc5200b-fec-phy";
+			reg = <3000 400>;	// fec range, since we need to setup fec interrupts
+			interrupts = <2 5 0>;	// these are for "mii command finished", not link changes & co.
+			interrupt-parent = <&mpc5200_pic>;
+
+			phy0:ethernet-phy@0 {
+				device_type = "ethernet-phy";
+				reg = <0>;
+			};
 		};
 
 		ata@3a00 {
