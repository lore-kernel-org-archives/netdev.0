From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/6] Documentation: DT binding doc for iProc Shared MDIO
 Controller.
Date: Fri, 22 Apr 2016 15:10:45 -0500
Message-ID: <20160422201045.GA32303@rob-hp-laptop>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-3-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Suzuki K Poulose <suzuki.poulose@arm.com>,
	netdev@vger.kernel.org, Punit Agrawal <punit.agrawal@arm.com>,
	linux-kernel@vger.kernel.org,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:33010 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084AbcDVUKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 16:10:52 -0400
Content-Disposition: inline
In-Reply-To: <1461230323-27891-3-git-send-email-pramod.kumar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 02:48:39PM +0530, Pramod Kumar wrote:
> Add DT binding doc for iProc Shared MDIO Controller which
> populate all masters to Shared MDIO framework.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> Reviewed-by: Ray Jui <ray.jui@broadcom.com>
> Reviewed-by: Scott Branden <scott.branden@broadcom.com>
> ---
>  .../bindings/bus/brcm,iproc-shared-mdio.txt        | 76 ++++++++++++++++++++++
>  1 file changed, 76 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
> 
> diff --git a/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt b/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
> new file mode 100644
> index 0000000..f455f3d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
> @@ -0,0 +1,76 @@
> +Broadcom iProc Shared MDIO Controller
> +
> +Required properties:
> +- compatible:
> +    "brcm,iproc-shared-mdio" for shared MDIO controller.
> +- reg: specifies the base physical address and size of the registers
> +- reg-names: should be "mdio"
> +- #address-cells: must be 1.
> +- #size-cells: must be 0.
> +
> +optional:
> +child nodes: Masters are represented as a child node of shared MDIO controller
> +and all the PHYs handled by this master are represented as its child node.

Seems kind of useless if child nodes are optional.

> +
> +Master nodes properties are defined as-
> +
> +Required properties:
> +- compatible: Used to match driver of this PHY.
> +- reg: MDIO master ID.
> +- #address-cells: must be 1.
> +- #size-cells: must be 0.
> +
> +optional:
> +-brcm,phy-internal: if presents, PHYs are internal. Absence shows phy is
> +external.
> +-brcm,is-c45: if presents, Controller uses Clause-45 to issue MDIO transaction.
> +else Controller uses Clause-22 for transactions.

Isn't this a property of the phy? IIRC, there is a standard property or 
compatible string for this.

> +
> +PHY nodes are represented as the child node of Master. Child nodes properties
> +are defined as-
> +
> +Required properties:
> +-reg: phy id of attached PHY.
> +
> +optional:
> +There could be additional properties required to configure the specific phy like
> +phy-mode in case of gpphy node below. These should be defined here and used by
> +respective drivers.
> +
> +Example:
> +iproc_mdio: iproc_mdio@663f0000 {
> +	compatible = "brcm,iproc-shared-mdio";
> +	reg = <0x6602023c 0x14>;
> +	reg-names = "mdio";
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +
> +	sata-master@6 {

mdio@6

> +		compatible = "brcm,iproc-ns2-sata-phy";
> +		reg = <0x6>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		brcm,phy-internal;
> +
> +		sata_phy0: sata-phy@1 {

phy@1

> +			reg = <0x1>;
> +			#phy-cells = <0>;
> +		};
> +
> +		sata_phy1: sata-phy@2 {

phy@2

> +			reg = <0x2>;
> +			#phy-cells = <0>;
> +		};
> +	};
> +
> +	eth-master@0 {

mdio@0

> +		compatible = "brcm,iproc-mdio-master-eth";
> +		reg = <0x0>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		gphy0: eth-phy@10 {

phy@10

> +			reg = <0x10>;
> +			phy-mode = "mii";
> +		};
> +	};
> +};
> -- 
> 1.9.1
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
