From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [RFC/RFT PATCH 4/4] [debug] ARM: am335x: illustrate hwstamp
Date: Tue, 13 Jun 2017 18:16:23 -0500
Message-ID: <20170613231623.28353-5-grygorii.strashko@ti.com>
References: <20170613231623.28353-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613231623.28353-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows to test CPTS HW_TS_PUSH functionality on am335x boards

below sequence of commands will enable Timer7 to trigger 1sec
periodic pulses on CPTS HW4_TS_PUSH input pin:

 # echo 1000000000 > /sys/class/pwm/pwmchip0/pwm0/period
 # echo 500000000 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
 # echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
 # ./ptp/testptp -e 10 -i 3
external time stamp request okay
event index 3 at 1493259028.376600798
event index 3 at 1493259029.377170898
event index 3 at 1493259030.377741039
event index 3 at 1493259031.378311139
event index 3 at 1493259032.378881279
event index 3 at 1493259033.379451424
event index 3 at 1493259034.380021520
event index 3 at 1493259035.380591660
event index 3 at 1493259036.381161765
event index 3 at 1493259037.381731909

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 arch/arm/boot/dts/am335x-boneblack.dts | 6 ++++++
 arch/arm/boot/dts/am335x-evm.dts       | 7 +++++++
 arch/arm/boot/dts/am33xx.dtsi          | 1 +
 arch/arm/configs/omap2plus_defconfig   | 2 +-
 4 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/am335x-boneblack.dts b/arch/arm/boot/dts/am335x-boneblack.dts
index 935ed17..997f5b4 100644
--- a/arch/arm/boot/dts/am335x-boneblack.dts
+++ b/arch/arm/boot/dts/am335x-boneblack.dts
@@ -25,4 +25,10 @@
 	oppnitro@1000000000 {
 		opp-supported-hw = <0x06 0x0100>;
 	};
+
+	pwm7: dmtimer-pwm {
+		compatible = "ti,omap-dmtimer-pwm";
+		ti,timers = <&timer7>;
+		#pwm-cells = <3>;
+	};
 };
diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
index 1c37a7c..ec36197 100644
--- a/arch/arm/boot/dts/am335x-evm.dts
+++ b/arch/arm/boot/dts/am335x-evm.dts
@@ -164,6 +164,13 @@
 			system-clock-frequency = <12000000>;
 		};
 	};
+
+	pwm7: dmtimer-pwm {
+		compatible = "ti,omap-dmtimer-pwm";
+		ti,timers = <&timer7>;
+		#pwm-cells = <3>;
+	};
+
 };
 
 &am33xx_pinmux {
diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
index 9e24294..1a64b80 100644
--- a/arch/arm/boot/dts/am33xx.dtsi
+++ b/arch/arm/boot/dts/am33xx.dtsi
@@ -864,6 +864,7 @@
 			ranges;
 			syscon = <&scm_conf>;
 			status = "disabled";
+			cpts-ext-ts-inputs = <4>;
 
 			davinci_mdio: mdio@4a101000 {
 				compatible = "ti,cpsw-mdio","ti,davinci_mdio";
diff --git a/arch/arm/configs/omap2plus_defconfig b/arch/arm/configs/omap2plus_defconfig
index a120ae8..6d3dcbc 100644
--- a/arch/arm/configs/omap2plus_defconfig
+++ b/arch/arm/configs/omap2plus_defconfig
@@ -459,7 +459,7 @@ CONFIG_CPCAP_ADC=m
 CONFIG_TI_AM335X_ADC=m
 CONFIG_BMP280=m
 CONFIG_PWM=y
-CONFIG_PWM_OMAP_DMTIMER=m
+CONFIG_PWM_OMAP_DMTIMER=y
 CONFIG_PWM_TIECAP=m
 CONFIG_PWM_TIEHRPWM=m
 CONFIG_PWM_TWL=m
-- 
2.10.1
