From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [PATCH v2] irqchip/renesas-irqc: Postpone driver initialization
Date: Wed, 9 Nov 2016 09:03:41 +0000
Message-ID: <3c801796-fef9-b589-4a05-da9e9ab9599d@arm.com>
References: <1478633747-26878-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        Thomas Gleixner <tglx@linutronix.de>,
        Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478633747-26878-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

On 08/11/16 19:35, Geert Uytterhoeven wrote:
> Currently the renesas-irqc driver uses postcore_initcall().
> 
> However, the new CPG/MSSR driver uses subsys_initcall(). Hence the
> IRQC's probe will be deferred, which causes the Micrel Ethernet PHY to
> not find its interrupt on R-Car Gen2 and RZ/G, as the of_mdio subsystem
> does not support deferred probe yet.
> 
> Replace postcore_initcall() by device_initcall() to work around this.
> 
> Note that on R-Mobile APE6, where the PFC/GPIO combo uses the IRQC as
> its parent interrupt controller, this does cause a few additional probe
> deferrals (for SCIFA0, SD0, SD1, and MMC). But the affected drivers
> handle that fine.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> ---
> v2:
>   - Drop RFC state,
>   - Add Tested-by,
>   - Improved description.
> ---
>  drivers/irqchip/irq-renesas-irqc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/irqchip/irq-renesas-irqc.c b/drivers/irqchip/irq-renesas-irqc.c
> index 52304b139aa46a60..992849e54d00ea77 100644
> --- a/drivers/irqchip/irq-renesas-irqc.c
> +++ b/drivers/irqchip/irq-renesas-irqc.c
> @@ -295,7 +295,7 @@ static int __init irqc_init(void)
>  {
>  	return platform_driver_register(&irqc_device_driver);
>  }
> -postcore_initcall(irqc_init);
> +device_initcall(irqc_init);

Overall, I'm not keen on these hacks (by moving from one initcall to
another, you're as likely to fix something than to break something else).

What should really be done is to either teach the various drivers to
handle deferred probing, or to teach the kernel to handle proper
dependencies (vastly more ambitious).

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
