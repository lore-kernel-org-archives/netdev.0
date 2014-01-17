From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH RFC 6/6] ARM: sun7i: cubietruck: enable
 bluetooth module
Date: Fri, 17 Jan 2014 14:47:31 +0800
Message-ID: <1389941251-32692-7-git-send-email-wens@csie.org>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBCNE4OLAKGQEBKPUNCA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1389941251-32692-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

The CubieTruck has an AMPAK AP6210 WiFi+Bluetooth module. The
Bluetooth part is a BCM20710 device connected to UART2 in the
A20 SoC.

The IC also requires a 32.768 KHz low power clock input for
proper auto-detection of the main clock, and power enable and
wake signals via GPIO.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 arch/arm/boot/dts/sun7i-a20-cubietruck.dts | 37 ++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
index c8b3ea9..f172a8f 100644
--- a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
+++ b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
@@ -78,6 +78,20 @@
 					allwinner,drive = <0>;
 					allwinner,pull = <2>;
 			};
+
+			bt_pwr_pin: bt_pwr_pin@0 {
+				allwinner,pins = "PH18";
+				allwinner,function = "gpio_out";
+				allwinner,drive = <0>;
+				allwinner,pull = <0>;
+			};
+
+			bt_wake_pin: bt_wake_pin@0 {
+				allwinner,pins = "PH24";
+				allwinner,function = "gpio_out";
+				allwinner,drive = <0>;
+				allwinner,pull = <0>;
+			};
 		};
 
 		uart0: serial@01c28000 {
@@ -86,6 +100,12 @@
 			status = "okay";
 		};
 
+		uart2: serial@01c28800 {
+			pinctrl-names = "default";
+			pinctrl-0 = <&uart2_pins_a>;
+			status = "okay";
+		};
+
 		gmac: ethernet@01c50000 {
 			pinctrl-names = "default";
 			pinctrl-0 = <&gmac_pins_rgmii>;
@@ -157,4 +177,21 @@
 			gpio = <&pio 7 3 0>;
 		};
 	};
+
+	rfkill-switches {
+		compatible = "simple-bus";
+		pinctrl-names = "default";
+
+		rfkill_bt {
+			compatible = "rfkill-gpio";
+			pinctrl-names = "default";
+			pinctrl-0 = <&bt_pwr_pin>, <&clk_out_a_pins>;
+			rfkill-name = "bt";
+			rfkill-type = <2>;
+			bt_shutdown-gpios = <0>, <&pio 7 18 0>; /* PH18 */
+			bt_reset-gpios = <&pio 7 24 0>; /* PH24 */
+			clocks = <&clk_out_a>;
+			clock-frequency = <32768>;
+		};
+	};
 };
-- 
1.8.5.2
