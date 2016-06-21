From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Tue, 21 Jun 2016 11:18:39 +1000
Message-ID: <20160621111839.34936836@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
 Pramod Kumar <pramod.kumar@broadcom.com>, linux-kernel@vger.kernel.org,
 Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>,
 linux-next@vger.kernel.org, Jon Mason <jon.mason@broadcom.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>, Olof
 Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
 <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got conflicts in:

  arch/arm64/boot/dts/broadcom/ns2-svk.dts
  arch/arm64/boot/dts/broadcom/ns2.dtsi

between commits:

  97b1504a30b3 ("arm64: dts: enable pinctrl for Broadcom NS2 SoC")
  5dcc9c7618df ("arm64: dts: NS2: Add CCI-400 PMU support")

from the arm-soc tree and commit:

  5f1a067bfa0a ("dt: mdio-mux: Add mdio multiplexer driver node")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc arch/arm64/boot/dts/broadcom/ns2-svk.dts
index b062a44a39c7,ea5603fd106a..000000000000
--- a/arch/arm64/boot/dts/broadcom/ns2-svk.dts
+++ b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
@@@ -161,11 -141,10 +169,19 @@@
  	};
  };
  
 +&pinctrl {
 +	pinctrl-names = "default";
 +	pinctrl-0 = <&nand_sel>;
 +	nand_sel: nand_sel {
 +		function = "nand";
 +		groups = "nand_grp";
 +	};
 +};
++
+ &mdio_mux_iproc {
+ 	mdio@10 {
+ 		gphy0: eth-phy@10 {
+ 			reg = <0x10>;
+ 		};
+ 	};
+ };
diff --cc arch/arm64/boot/dts/broadcom/ns2.dtsi
index d1dc812daaab,46b78fa89f4c..000000000000
--- a/arch/arm64/boot/dts/broadcom/ns2.dtsi
+++ b/arch/arm64/boot/dts/broadcom/ns2.dtsi
@@@ -279,26 -263,45 +279,65 @@@
  				      IRQ_TYPE_LEVEL_HIGH)>;
  		};
  
 +		cci@65590000 {
 +			compatible = "arm,cci-400";
 +			#address-cells = <1>;
 +			#size-cells = <1>;
 +			reg = <0x65590000 0x1000>;
 +			ranges = <0 0x65590000 0x10000>;
 +
 +			pmu@9000 {
 +				compatible = "arm,cci-400-pmu,r1",
 +					     "arm,cci-400-pmu";
 +				reg = <0x9000 0x4000>;
 +				interrupts = <GIC_SPI 344 IRQ_TYPE_LEVEL_HIGH>,
 +					     <GIC_SPI 345 IRQ_TYPE_LEVEL_HIGH>,
 +					     <GIC_SPI 346 IRQ_TYPE_LEVEL_HIGH>,
 +					     <GIC_SPI 347 IRQ_TYPE_LEVEL_HIGH>,
 +					     <GIC_SPI 348 IRQ_TYPE_LEVEL_HIGH>,
 +					     <GIC_SPI 349 IRQ_TYPE_LEVEL_HIGH>;
 +			};
 +		};
 +
+ 		mdio_mux_iproc: mdio-mux@6602023c {
+ 			compatible = "brcm,mdio-mux-iproc";
+ 			reg = <0x6602023c 0x14>;
+ 			#address-cells = <1>;
+ 			#size-cells = <0>;
+ 
+ 			mdio@0 {
+ 				reg = <0x0>;
+ 				#address-cells = <1>;
+ 				#size-cells = <0>;
+ 
+ 				pci_phy0: pci-phy@0 {
+ 					compatible = "brcm,ns2-pcie-phy";
+ 					reg = <0x0>;
+ 					#phy-cells = <0>;
+ 					status = "disabled";
+ 				};
+ 			};
+ 
+ 			mdio@7 {
+ 				reg = <0x7>;
+ 				#address-cells = <1>;
+ 				#size-cells = <0>;
+ 
+ 				pci_phy1: pci-phy@0 {
+ 					compatible = "brcm,ns2-pcie-phy";
+ 					reg = <0x0>;
+ 					#phy-cells = <0>;
+ 					status = "disabled";
+ 				};
+ 			};
+ 
+ 			mdio@10 {
+ 				reg = <0x10>;
+ 				#address-cells = <1>;
+ 				#size-cells = <0>;
+ 			};
+ 		};
+ 
  		timer0: timer@66030000 {
  			compatible = "arm,sp804", "arm,primecell";
  			reg = <0x66030000 0x1000>;
