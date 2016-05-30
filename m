From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/7] binding: mdio-mux: Add DT binding doc for Broadcom
 MDIO bus mutiplexer
Date: Mon, 30 May 2016 17:24:26 +0200
Message-ID: <20160530152426.GM6027@lunn.ch>
References: <1464592251-2688-1-git-send-email-pramod.kumar@broadcom.com>
 <1464592251-2688-4-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464592251-2688-4-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 30, 2016 at 12:40:47PM +0530, Pramod Kumar wrote:
> Add DT binding doc for Broadcom MDIO bus mutiplexer driver.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> ---
>  .../bindings/net/brcm,mdio-mux-iproc.txt           | 64 ++++++++++++++++++++++
>  1 file changed, 64 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> new file mode 100644
> index 0000000..dd74ee0
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> @@ -0,0 +1,64 @@
> +Properties for an MDIO bus mutiplexer found in Broadcom iProc based SoCs.
> +
> +This MDIO bus multiplexer defines buses that could be internal as well as
> +external to SoCs and could accept MDIO transaction compatible to C-22 or
> +C-45 Clause. When Child bus is selected, one need to select these two
> +properties as well to generate desired MDIO trascation on appropriate bus.
> +
> +Required properties in addition to the generic multiplexer properties:
> +
> +MDIO multiplexer node:
> +- complatible: brcm,mdio-mux-iproc.
> +
> +Child bus node:
> +-brcm,is-c45: Boolean property indicating PHYs attached to this bus supports
> +	      C-45 mdio transaction.

This is-c45 seems to be at the wrong level. As far as i know, you can
mix C22 and C45 devices on a bus. It is a property of the individual
MDIO device if it uses C45 or not.

I would expect your MDIO device PHY drivers to logically OR
MII_ADDR_C45 into the address when doing an MDIO read/write using C45.

	     Andrew
