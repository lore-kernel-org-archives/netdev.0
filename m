From: Kever Yang <kever.yang@rock-chips.com>
Subject: Re: [PATCH 4/4] GMAC: dts: enable gmac on RK3288 evb board
Date: Tue, 25 Nov 2014 17:59:12 +0800
Message-ID: <547452F0.1080307@rock-chips.com>
References: <1416906549-26196-1-git-send-email-roger.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	mark.yao@rock-chips.com, eddie.cai@rock-chips.com
To: Roger Chen <roger.chen@rock-chips.com>, heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416906549-26196-1-git-send-email-roger.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Roger,

The subject should prefix:
Arm: dts: rockchip: enable ...

On 11/25/2014 05:09 PM, Roger Chen wrote:
> enable gmac in rk3288-evb-rk808.dts
>
> Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
> ---
>   arch/arm/boot/dts/rk3288-evb-rk808.dts |   22 ++++++++++++++++++++++
>   1 file changed, 22 insertions(+)
>
> diff --git a/arch/arm/boot/dts/rk3288-evb-rk808.dts b/arch/arm/boot/dts/rk3288-evb-rk808.dts
> index d8c775e6..168b4fa 100644
> --- a/arch/arm/boot/dts/rk3288-evb-rk808.dts
> +++ b/arch/arm/boot/dts/rk3288-evb-rk808.dts
> @@ -152,3 +152,25 @@
>   		};
>   	};
>   };
> +
> +&ext_gmac {
> +	clock-frequency = <125000000>;
> +	clock-output-names = "ext_gmac";
> +};
> +
> +&gmac {
> +	//pmu_regulator = "act_ldo5";
> +	//pmu_enable_level = <1>; //1->HIGH, 0->LOW
remove these unused code.
> +	power-gpio = <&gpio0 6 GPIO_ACTIVE_HIGH>;
> +	reset-gpio = <&gpio4 7 GPIO_ACTIVE_LOW>;
> +	//phyirq-gpio = <&gpio4 2 GPIO_ACTIVE_LOW>;
same.
> +	phy-mode = "rgmii";
> +	clock_in_out = "input";
> +	assigned-clocks = <&cru SCLK_MAC>;
> +	assigned-clock-parents = <&ext_gmac>;
> +	pinctrl-names = "default";
> +	pinctrl-0 = <&rgmii_pin>; /*&rmii_pin*/
same.

- Kever
> +	tx_delay = <0x30>;
> +	rx_delay = <0x10>;
> +	status = "ok";
> +};
