From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Thu, 1 Dec 2016 12:31:36 +1100
Message-ID: <20161201123136.38d9876f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rob Rice <rrice@broadcom.com>, Florian Fainelli <f.fainelli@gmail.com>,
 linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
 Jon Mason <jon.mason@broadcom.com>
To: David Miller <davem@davemloft.net>, Networking <netdev@vger.kernel.org>,
 Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>, ARM
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

Today's linux-next merge of the net-next tree got a conflict in:

  arch/arm64/boot/dts/broadcom/ns2.dtsi

between commit:

  e79249143f46 ("arm64: dts: Add Broadcom Northstar2 device tree entries for PDC driver.")

from the arm-soc tree and commit:

  dddc3c9d7d02 ("arm64: dts: NS2: add AMAC ethernet support")

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

diff --cc arch/arm64/boot/dts/broadcom/ns2.dtsi
index 863503d78f57,773ed593da4d..000000000000
--- a/arch/arm64/boot/dts/broadcom/ns2.dtsi
+++ b/arch/arm64/boot/dts/broadcom/ns2.dtsi
@@@ -197,42 -191,18 +197,54 @@@
  
  		#include "ns2-clock.dtsi"
  
 +		pdc0: iproc-pdc0@612c0000 {
 +			compatible = "brcm,iproc-pdc-mbox";
 +			reg = <0x612c0000 0x445>;  /* PDC FS0 regs */
 +			interrupts = <GIC_SPI 187 IRQ_TYPE_LEVEL_HIGH>;
 +			#mbox-cells = <1>;
 +			brcm,rx-status-len = <32>;
 +			brcm,use-bcm-hdr;
 +		};
 +
 +		pdc1: iproc-pdc1@612e0000 {
 +			compatible = "brcm,iproc-pdc-mbox";
 +			reg = <0x612e0000 0x445>;  /* PDC FS1 regs */
 +			interrupts = <GIC_SPI 189 IRQ_TYPE_LEVEL_HIGH>;
 +			#mbox-cells = <1>;
 +			brcm,rx-status-len = <32>;
 +			brcm,use-bcm-hdr;
 +		};
 +
 +		pdc2: iproc-pdc2@61300000 {
 +			compatible = "brcm,iproc-pdc-mbox";
 +			reg = <0x61300000 0x445>;  /* PDC FS2 regs */
 +			interrupts = <GIC_SPI 191 IRQ_TYPE_LEVEL_HIGH>;
 +			#mbox-cells = <1>;
 +			brcm,rx-status-len = <32>;
 +			brcm,use-bcm-hdr;
 +		};
 +
 +		pdc3: iproc-pdc3@61320000 {
 +			compatible = "brcm,iproc-pdc-mbox";
 +			reg = <0x61320000 0x445>;  /* PDC FS3 regs */
 +			interrupts = <GIC_SPI 193 IRQ_TYPE_LEVEL_HIGH>;
 +			#mbox-cells = <1>;
 +			brcm,rx-status-len = <32>;
 +			brcm,use-bcm-hdr;
 +		};
 +
+ 		enet: ethernet@61000000 {
+ 			compatible = "brcm,ns2-amac";
+ 			reg = <0x61000000 0x1000>,
+ 			      <0x61090000 0x1000>,
+ 			      <0x61030000 0x100>;
+ 			reg-names = "amac_base", "idm_base", "nicpm_base";
+ 			interrupts = <GIC_SPI 341 IRQ_TYPE_LEVEL_HIGH>;
+ 			phy-handle = <&gphy0>;
+ 			phy-mode = "rgmii";
+ 			status = "disabled";
+ 		};
+ 
  		dma0: dma@61360000 {
  			compatible = "arm,pl330", "arm,primecell";
  			reg = <0x61360000 0x1000>;
