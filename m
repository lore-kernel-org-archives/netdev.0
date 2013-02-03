From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 2/6] ARM: davinci: da850: add DT node for mdio device
Date: Sun, 3 Feb 2013 17:23:28 +0530
Message-ID: <510E4FB8.4050705@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
 <1359380879-26306-3-git-send-email-prabhakar.lad@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Lad,
 Prabhakar" <prabhakar.lad-l0cyMroinI0@public.gmane.org>, Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Prabhakar Lad <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1359380879-26306-3-git-send-email-prabhakar.lad-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 1/28/2013 7:17 PM, Prabhakar Lad wrote:
> From: Lad, Prabhakar <prabhakar.lad-l0cyMroinI0@public.gmane.org>
> 
> Add mdio device tree node information to da850 by
> providing register details and bus frequency of mdio.
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.lad-l0cyMroinI0@public.gmane.org>
> Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
> Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
> ---
>  arch/arm/boot/dts/da850-evm.dts |    3 +++
>  arch/arm/boot/dts/da850.dtsi    |    7 +++++++
>  2 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/da850-evm.dts b/arch/arm/boot/dts/da850-evm.dts
> index 98c1a48..a319491 100644
> --- a/arch/arm/boot/dts/da850-evm.dts
> +++ b/arch/arm/boot/dts/da850-evm.dts
> @@ -27,6 +27,9 @@
>  		serial2: serial@1d0d000 {
>  			status = "okay";
>  		};
> +		mdio: davinci_mdio@1e24000 {

This should just be:

mdio: mdio@1e24000

inline with how we avoid adding davinci prefix to each node name.

> +			status = "okay";
> +		};
>  	};
>  	nand_cs3@62000000 {
>  		status = "okay";
> diff --git a/arch/arm/boot/dts/da850.dtsi b/arch/arm/boot/dts/da850.dtsi
> index 7c84822..ba28f2d 100644
> --- a/arch/arm/boot/dts/da850.dtsi
> +++ b/arch/arm/boot/dts/da850.dtsi
> @@ -81,6 +81,13 @@
>  			interrupts = <61>;
>  			status = "disabled";
>  		};
> +		mdio: davinci_mdio@1e24000 {
> +			compatible = "ti,davinci_mdio";
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <0x224000 0x1000>;
> +			bus_freq = <2200000>;

The bus frequency is board specific and it is better this is defined in
da850-evm.dts

Thanks,
Sekhar
