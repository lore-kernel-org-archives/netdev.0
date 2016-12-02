From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2] sh_eth: remove unchecked interrupts
Date: Fri, 2 Dec 2016 13:18:17 +0100
Message-ID: <CAMuHMdXGufhc9ZnW8s_ntopBn2Cv4rTu5+PcTtzELxff8ggihA@mail.gmail.com>
References: <20161201140642.28583-1-chris.brandt@renesas.com>
 <CAMuHMdU80M2qcK74YgPC8SZ20tNcKrZhj7MXo_Ok=6m4Aa0=-w@mail.gmail.com>
 <25b92de0-806b-342b-7556-06b96b948b2c@cogentembedded.com> <SG2PR06MB1165C7D7B7DFBAC4B5BAB09A8A8F0@SG2PR06MB1165.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        David Miller <davem@davemloft.net>,
        Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Chris Brandt <Chris.Brandt@renesas.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB1165C7D7B7DFBAC4B5BAB09A8A8F0@SG2PR06MB1165.apcprd06.prod.outlook.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chris,

On Thu, Dec 1, 2016 at 7:53 PM, Chris Brandt <Chris.Brandt@renesas.com> wrote:
> On 12/1/2016, Sergei Shtylyov wrote:
>>
>> On 12/01/2016 05:42 PM, Geert Uytterhoeven wrote:
>>
>> >> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> >> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> >> @@ -518,7 +518,7 @@ static struct sh_eth_cpu_data r7s72100_data = {
>> >>
>> >>         .ecsr_value     = ECSR_ICD,
>> >>         .ecsipr_value   = ECSIPR_ICDIP,
>> >> -       .eesipr_value   = 0xff7f009f,
>> >> +       .eesipr_value   = 0xe77f009f,
>> >
>> > Comment not directly related to the merits of this patch: the EESIPR
>> > bit definitions seem to be identical to those for EESR, so we can get
>> > rid of the hardcoded values here?
>>
>>     Do you mean using the @define's? We have EESIPR bits also declared,
>> see enum DMAC_IM_BIT,

Yes, that's what I meant.
Unfortunately the DMAC_IM_BIT enum doesn't cover all bits.

> Is your idea to get rid of .eesipr_value for devices that have values
> that are the same as .eesr_err_check?
>
>
> For example in sh_eth_dev_init():
>
>         sh_eth_modify(ndev, EESR, 0, 0);
>         mdp->irq_enabled = true;
> -       sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
> +       if (mdp->cd->eesipr_value)
> +               sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
> +       else
> +               sh_eth_write(ndev, mdp->cd->eesr_err_check, EESIPR);

No, my intention was to just get rid of the hardcoded values when
initializing .eesipr_value.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
