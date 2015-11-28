From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 2/3] dts: hisi: fixes no syscon error when init mdio
Date: Sat, 28 Nov 2015 14:15:15 +0800
Message-ID: <1448691316-236111-3-git-send-email-yankejian@huawei.com>
References: <1448691316-236111-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>, <xuwei5@hisilicon.com>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<wangkefeng.wang@huawei.com>, <dingtianhong@huawei.com>,
	<liguozhu@huawei.com>, <Yisen.Zhuang@huawei.com>,
	<sboyd@codeaurora.org>, <haojian.zhuang@linaro.org>,
	<wangzhou1@hisilicon.com>, <bintian.wang@huawei.com>,
	<long.wanglong@huawei.com>, <leo.yan@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448691316-236111-1-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

when linux start up, we get the log below:
"Hi-HNS_MDIO 803c0000.mdio: no syscon hisilicon,peri-c-subctrl
 mdio_bus mdio@803c0000: mdio sys ctl reg has not maped       "

the source code about the subctrl is dealled with syscon, but dts doesn't.
it cause such fault. so this patch adds the syscon info on dts files to
fixes it.

Signed-off-by: yankejian <yankejian@huawei.com>
---
 arch/arm64/boot/dts/hisilicon/hip05.dtsi     | 4 ++++
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi | 4 ++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/boot/dts/hisilicon/hip05.dtsi b/arch/arm64/boot/dts/hisilicon/hip05.dtsi
index 4ff16d0..daaca63 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05.dtsi
+++ b/arch/arm64/boot/dts/hisilicon/hip05.dtsi
@@ -246,6 +246,10 @@
 			clock-frequency = <200000000>;
 		};
 
+		peri_c_subctrl: sub_ctrl_c@80000000 {
+			compatible = "hisilicon,peri-c-subctrl", "syscon";
+			reg = < 0x0 0x80000000 0x0 0x10000>;
+		};
 		uart0: uart@80300000 {
 			compatible = "snps,dw-apb-uart";
 			reg = <0x0 0x80300000 0x0 0x10000>;
diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
index 606dd5a..4d4815e 100644
--- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
+++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
@@ -10,8 +10,8 @@ soc0: soc@000000000 {
 		#address-cells = <1>;
 		#size-cells = <0>;
 		compatible = "hisilicon,hns-mdio";
-		reg = <0x0 0x803c0000 0x0 0x10000
-		       0x0 0x80000000 0x0 0x10000>;
+		reg = <0x0 0x803c0000 0x0 0x10000>;
+		subctrl_vbase = <&peri_c_subctrl>;
 
 		soc0_phy0: ethernet-phy@0 {
 			reg = <0x0>;
-- 
1.9.1
