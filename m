From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 6/6] ARM: davinci: da850: configure system configuration
 chip(CFGCHIP3) for emac
Date: Sun, 3 Feb 2013 18:15:03 +0530
Message-ID: <510E5BCF.9080006@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
 <1359380879-26306-7-git-send-email-prabhakar.lad@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Lad,
 Prabhakar" <prabhakar.lad-l0cyMroinI0@public.gmane.org>, Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Prabhakar Lad <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1359380879-26306-7-git-send-email-prabhakar.lad-l0cyMroinI0@public.gmane.org>
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
> The system configuration chip CFGCHIP3, controls the emac module.
> This patch appropriately configures this register for emac and
> sets DA850_MII_MDIO_CLKEN_PIN GPIO pin appropriately.
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
>  arch/arm/mach-davinci/da8xx-dt.c |   28 ++++++++++++++++++++++++++++
>  1 files changed, 28 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/arm/mach-davinci/da8xx-dt.c b/arch/arm/mach-davinci/da8xx-dt.c
> index e533a0a..4a096e3 100644
> --- a/arch/arm/mach-davinci/da8xx-dt.c
> +++ b/arch/arm/mach-davinci/da8xx-dt.c
> @@ -8,6 +8,7 @@
>   * published by the Free Software Foundation.
>   */
>  #include <linux/io.h>
> +#include <linux/gpio.h>
>  #include <linux/of_irq.h>
>  #include <linux/of_platform.h>
>  #include <linux/irqdomain.h>
> @@ -39,6 +40,32 @@ static void __init da8xx_init_irq(void)
>  
>  #ifdef CONFIG_ARCH_DAVINCI_DA850
>  
> +static void __init da8xx_config_emac(void)
> +{
> +#define DA850_MII_MDIO_CLKEN_PIN	GPIO_TO_PIN(2, 6)
> +#define DA850_EMAC_MODE_SELECT		BIT(8)
> +	void __iomem *cfg_chip3_base;
> +	int ret;
> +	u32 val;
> +
> +	cfg_chip3_base = DA8XX_SYSCFG0_VIRT(DA8XX_CFGCHIP3_REG);
> +
> +	val = __raw_readl(cfg_chip3_base);
> +	val &= ~DA850_EMAC_MODE_SELECT;
> +	/* configure the CFGCHIP3 register for MII */
> +	__raw_writel(val, cfg_chip3_base);

Use readl/writel instead.

> +	pr_info("EMAC: MII PHY configured\n");
> +
> +	ret = gpio_request(DA850_MII_MDIO_CLKEN_PIN, "mdio_clk_en");
> +	if (ret) {
> +		pr_warn("Cannot open GPIO %d\n",
> +					DA850_MII_MDIO_CLKEN_PIN);
> +		return;
> +	}
> +	/* Enable/Disable MII MDIO clock */
> +	gpio_direction_output(DA850_MII_MDIO_CLKEN_PIN, 0);
> +}
> +
>  struct of_dev_auxdata da8xx_auxdata[] __initdata = {
>  	OF_DEV_AUXDATA("ti,davinci_mdio", 0x01e24000, "davinci_mdio.0", NULL),
>  	OF_DEV_AUXDATA("ti,davinci-dm6467-emac", 0x01e20000, "davinci_emac.1",
> @@ -52,6 +79,7 @@ static void __init da850_init_machine(void)
>  			     da8xx_auxdata, NULL);
>  
>  	da8xx_uart_clk_enable();
> +	da8xx_config_emac();

There are couple of issues with this implementation.

1) da8xx_config_emac() is specific to DA850 EVM, but masquerades as
   generic for da8xx. Looks like you need two functions, one for soc
   specific configuration and one board specific.
2) da8xx_config_emac() goes through all the time, whether the
   particular board has emac module or not. Shouldn't
   da8xx_config_emac() check if emac is actually enabled in the passed
   dtb and only the do the configuration?
3) The function assumes mii is used always, you can use the rmii_en dt
   property to check if rmii/mii is enabled and configure the soc/board
   accordingly.
4) If the same function can work both for da850 and da830, then it can
   be implemented outside of CONFIG_ARCH_DAVINCI_DA850.

Thanks,
Sekhar
