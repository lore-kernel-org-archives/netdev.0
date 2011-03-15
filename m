From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCHv2 1/9] at91: provide macb clks with "pclk" and "hclk" name
Date: Tue, 15 Mar 2011 13:35:39 +0100
Message-ID: <20110315123539.GD14548@game.jcrosoft.org>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
	<1300184096-13937-2-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com,
	linux-arm-kernel@lists.infradead.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1300184096-13937-2-git-send-email-jamie@jamieiles.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 10:14 Tue 15 Mar     , Jamie Iles wrote:
> The macb driver expects clocks with the names "pclk" and "hclk".  We
> currently provide "macb_clk" but to fit in line with other
> architectures (namely AVR32), provide "pclk" and a fake "hclk".
> 
> Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Signed-off-by: Jamie Iles <jamie@jamieiles.com>
> ---
>  arch/arm/mach-at91/at572d940hf.c |    8 +++++++-
>  arch/arm/mach-at91/at91cap9.c    |    8 +++++++-
>  arch/arm/mach-at91/at91sam9260.c |    8 +++++++-
>  arch/arm/mach-at91/at91sam9263.c |    8 +++++++-
>  arch/arm/mach-at91/at91sam9g45.c |    8 +++++++-
>  5 files changed, 35 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm/mach-at91/at572d940hf.c b/arch/arm/mach-at91/at572d940hf.c
> index a6b9c68..9b3a37e 100644
> --- a/arch/arm/mach-at91/at572d940hf.c
> +++ b/arch/arm/mach-at91/at572d940hf.c
> @@ -71,10 +71,15 @@ static struct clk pioC_clk = {
>  	.type		= CLK_TYPE_PERIPHERAL,
>  };
>  static struct clk macb_clk = {
> -	.name		= "macb_clk",
> +	.name		= "pclk",
>  	.pmc_mask	= 1 << AT572D940HF_ID_EMAC,
>  	.type		= CLK_TYPE_PERIPHERAL,
>  };
> +static struct clk macb_hclk = {
> +	.name		= "hclk",
> +	.pmc_mask	= 0,
> +	.type		= CLK_TYPE_PERIPHERAL,
> +};
for the fake clock you must specify the parent as macb_clk

take a look on the tcb1_clk for the 9g45

Best Regards,
J.
