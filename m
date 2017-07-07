From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: axienet: add support for standard phy-mode
 binding
Date: Fri, 7 Jul 2017 16:08:25 +0200
Message-ID: <20170707140825.GE24237@lunn.ch>
References: <20170707065015.9671-1-alvaro.gamez@hazent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170707065015.9671-1-alvaro.gamez@hazent.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2017 at 08:50:15AM +0200, Alvaro Gamez Machado wrote:
> Keep supporting proprietary "xlnx,phy-type" attribute and add support for
> MII connectivity to the PHY.
> 
> Signed-off-by: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
> ---
> 
> Changes since v1:
> 
> 	* Renamed phy_type to phy_mode.  No other instances of this struct
> 	  member were found except for those we wanted to change, so there's
> 	  no other hidden meaning behind this.
> 
> 	* Added Device Tree Binding document specifying required and
> 	optional properties, an example.  Also, make a explicit note of why
> 	this driver is incompatible with AXI DMA driver
> 
>  .../devicetree/bindings/net/xilinx_axienet.txt     | 55 ++++++++++++++++++++++
>  drivers/net/ethernet/xilinx/xilinx_axienet.h       |  4 +-
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c  | 48 ++++++++++++++-----
>  3 files changed, 93 insertions(+), 14 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/xilinx_axienet.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/xilinx_axienet.txt b/Documentation/devicetree/bindings/net/xilinx_axienet.txt
> new file mode 100644
> index 000000000000..38f9ec076743
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/xilinx_axienet.txt
> @@ -0,0 +1,55 @@
> +XILINX AXI ETHERNET Device Tree Bindings
> +--------------------------------------------------------
> +
> +Also called  AXI 1G/2.5G Ethernet Subsystem, the xilinx axi ethernet IP core
> +provides connectivity to an external ethernet PHY supporting different
> +interfaces: MII, GMII, RGMII, SGMII, 1000BaseX. It also includes two
> +segments of memory for buffering TX and RX, as well as the capability of
> +offloading TX/RX checksum calculation off the processor.
> +
> +Management configuration is done through the AXI interface, while payload is
> +sent and received through means of an AXI DMA controller. This driver
> +includes the DMA driver code, so this driver is incompatible with AXI DMA
> +driver.
> +
> +For more details about mdio please refer phy.txt file in the same directory.
> +
> +Required properties:
> +- compatible	: Must be one of "xlnx,axi-ethernet-1.00.a",
> +		  "xlnx,axi-ethernet-1.01.a", "xlnx,axi-ethernet-2.01.a"
> +- reg		: Address and length of the IO space.
> +- interrupts	: Should be a list of two interrupt, TX and RX.
> +- phy-handle	: Should point to the external phy device.
> +		  See ethernet.txt file in the same directory.
> +- xlnx,rxmem	: Set to allocated memory buffer for Rx/Tx in the hardware
> +
> +Optional properties:
> +- phy-mode	: See ethernet.txt
> +- xlnx,phy-type	: Deprecated, do not use, but still accepted in preference
> +		  to phy-mode.
> +- xlnx,txcsum	: 0 or empty for disabling TX checksum offload,
> +		  1 to enable partial TX checksum offload,
> +		  2 to enable full TX checksum offload
> +- xlnx,rxcsum	: Same values as xlnx,txcsum but for RX checksum offload

Hi Alvaro 

Nice, thanks for the fuller documentation.

> -		} else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
> -			phydev = of_phy_connect(lp->ndev, lp->phy_node,
> -						axienet_adjust_link, 0,
> -						PHY_INTERFACE_MODE_RGMII_ID);

> +		case XAE_PHY_TYPE_RGMII_2_0:
> +			lp->phy_mode = PHY_INTERFACE_MODE_RGMII;
> +			break;

Upps. Sorry, i added a bug! As you can see from the deleted code, 
XAE_PHY_TYPE_RGMII_2_0 == PHY_INTERFACE_MODE_RGMII_ID.

Once you have fixed this, please add my

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

netdev is closed for patches at the moment, due the merge window being
open. It should reopen in about 10 days. Please submit the patch then.

    Andrew
