From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 3/7] binding: mdio-mux: Add DT binding doc for
 Broadcom MDIO bus mutiplexer
Date: Thu, 2 Jun 2016 20:43:23 -0500
Message-ID: <20160603014323.GA12365@rob-hp-laptop>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
 <1464701801-17243-4-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464701801-17243-4-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2016 at 07:06:37PM +0530, Pramod Kumar wrote:
> Add DT binding doc for Broadcom MDIO bus mutiplexer driver.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> ---
>  .../bindings/net/brcm,mdio-mux-iproc.txt           | 60 ++++++++++++++++++++++
>  1 file changed, 60 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> new file mode 100644
> index 0000000..f270b41
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> @@ -0,0 +1,60 @@
> +Properties for an MDIO bus mutiplexer found in Broadcom iProc based SoCs.
> +
> +This MDIO bus multiplexer defines buses that could be internal as well as
> +external to SoCs and could accept MDIO transaction compatible to C-22 or
> +C-45 Clause. When Child bus is selected, one need to select these two

s/Child/child/

s/need/needs/

> +properties as well to generate desired MDIO trascation on appropriate bus.
> +
> +Required properties in addition to the generic multiplexer properties:
> +
> +MDIO multiplexer node:
> +- complatible: brcm,mdio-mux-iproc.

typo

> +
> +Every non-ethernet PHY requires a compatible so that it could be probed based
> +on this compatible string.
> +
> +Additional information regarding generic multiplexer properties could be found

s/could/can/

> +at- Documentation/devicetree/bindings/net/mdio-mux.txt
> +
> +
> +for example:
> +		mdio_mux_iproc: mdio_mux_iproc@6602023c {

No '_' in node names.

mdio-mux@...

> +			compatible = "brcm,mdio-mux-iproc";
> +			reg = <0x6602023c 0x14>;
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			mdio-integrated-mux;
> +
> +			mdio@0 {
> +				reg = <0x0>;
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +
> +				pci_phy0: pci-phy@0 {
> +					compatible = "brcm,ns2-pcie-phy";
> +					reg = <0x0>;
> +					#phy-cells = <0>;
> +				};
> +			};
> +
> +			mdio@7 {
> +				reg = <0x7>;
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +
> +				pci_phy1: pci-phy@0 {
> +					compatible = "brcm,ns2-pcie-phy";
> +					reg = <0x0>;
> +					#phy-cells = <0>;
> +				};
> +			};
> +			mdio@10 {
> +				reg = <0x10>;
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +
> +				gphy0: eth-phy@10 {
> +					reg = <0x10>;
> +				};
> +			};
> +		};
> -- 
> 1.9.1
> 
