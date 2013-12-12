From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2 0/5] net: macb updates
Date: Thu, 12 Dec 2013 15:28:43 +0100
Message-ID: <52A9C81B.7050007@atmel.com>
References: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com> <CAOesGMjcmeiBfc=EOvWazebg-9vnMuQtRC0aeHJy7Q=02RdRPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
To: Olof Johansson <olof@lixom.net>,
	Soren Brinkmann <soren.brinkmann@xilinx.com>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	boris brezillon <b.brezillon@overkiz.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOesGMjcmeiBfc=EOvWazebg-9vnMuQtRC0aeHJy7Q=02RdRPA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/12/2013 08:00, Olof Johansson :
> Hi Soren,
>
> On Tue, Dec 10, 2013 at 4:07 PM, Soren Brinkmann
> <soren.brinkmann@xilinx.com> wrote:
>
>> Soren Brinkmann (5):
>>    net: macb: Adjust tx_clk when link speed changes
>
> This patch causes build issues on some at91 platforms, namely
> at91sam9263 that lacks programmable clocks. So it doesn't implement
> clk_set_rate() and clk_round_rate().
>
> I don't know if there's any reasonable config option to check for
> (that wouldn't add at91-specific stuff to the driver which we don't
> want). So I suspect the best way would be to implement dummy versions
> for at91 when CONFIG_AT91_PROGRAMMABLE_CLOCKS isn't set.
>
> Nicolas, you OK with that? It'd be something like the below
> (copy-paste, whitespace damage, just RFC):

Well, in fact I am thinking about simply removing this 
AT91_PROGRAMMABLE_CLOCKS option out of the AT91 Kconfig.

After all, when not specified, it only removes a few lines of code... 
and that's it! For a so little benefit, I suspect it is sensible to 
remove this option.
I continue to discuss with AT91 active developers and write a patch soon.

Thanks for the heads-up on this issue Olof.

Bye,


> diff --git a/arch/arm/mach-at91/clock.c b/arch/arm/mach-at91/clock.c
> index 6b2630a..17c52a7 100644
> --- a/arch/arm/mach-at91/clock.c
> +++ b/arch/arm/mach-at91/clock.c
> @@ -459,6 +459,22 @@ static void __init init_programmable_clock(struct clk *clk)
>          clk->rate_hz = parent->rate_hz / pmc_prescaler_divider(pckr);
>   }
>
> +#else  /* CONFIG_AT91_PROGRAMMABLE_CLOCKS */
> +
> +int clk_set_rate(struct clk *clk, unsigned long rate)
> +{
> +       if (rate == clk_get_rate(clk))
> +               return 0;
> +
> +       return -EINVAL;
> +}
> +
> +long clk_round_rate(struct clk *clk, unsigned long rate)
> +{
> +       /* There's really nothing sane to return here. */
> +       return clk_get_rate(clk);
> +}
> +
>   #endif /* CONFIG_AT91_PROGRAMMABLE_CLOCKS */
>


-- 
Nicolas Ferre
