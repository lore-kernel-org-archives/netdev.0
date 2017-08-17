From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4 06/12] net: stmmac: dwmac-rk: Add internal phy support
Date: Thu, 17 Aug 2017 10:10:28 -0500
Message-ID: <20170817151028.ewrgdk7qqd3nqzhe@rob-hp-laptop>
References: <1502280475-736-1-git-send-email-david.wu@rock-chips.com>
 <1502280661-2308-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, huangtao@rock-chips.com,
        hwg@rock-chips.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1502280661-2308-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2017 at 08:11:01PM +0800, David Wu wrote:
> To make internal phy work, need to configure the phy_clock,
> phy cru_reset and related registers.
> 
> Signed-off-by: David Wu <david.wu@rock-chips.com>
> ---
> change in v4:
>  - PHY is internal or not base on the phy-is-internal property via phy node.
> 
>  .../devicetree/bindings/net/rockchip-dwmac.txt     |  4 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 88 ++++++++++++++++++++++
>  2 files changed, 91 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> index 8f42755..4f51305 100644
> --- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> @@ -25,7 +25,8 @@ Required properties:
>   - clock-names: One name for each entry in the clocks property.
>   - phy-mode: See ethernet.txt file in the same directory.
>   - pinctrl-names: Names corresponding to the numbered pinctrl states.
> - - pinctrl-0: pin-control mode. can be <&rgmii_pins> or <&rmii_pins>.
> + - pinctrl-0: pin-control mode. can be <&rgmii_pins>, <&rmii_pins> or led pins
> +   for internal phy mode.
>   - clock_in_out: For RGMII, it must be "input", means main clock(125MHz)
>     is not sourced from SoC's PLL, but input from PHY; For RMII, "input" means
>     PHY provides the reference clock(50MHz), "output" means GMAC provides the
> @@ -40,6 +41,7 @@ Optional properties:
>   - tx_delay: Delay value for TXD timing. Range value is 0~0x7F, 0x30 as default.
>   - rx_delay: Delay value for RXD timing. Range value is 0~0x7F, 0x10 as default.
>   - phy-supply: phandle to a regulator if the PHY needs one
> + - clocks: <&cru MAC_PHY>: Clock selector for internal macphy

I assume this is required if internal phy is used. 'clocks' is already 
documented above, so this needs to be documented with it.

Rob
