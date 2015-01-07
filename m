From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] sh_eth: Fix access to TRSCER register
Date: Thu, 8 Jan 2015 08:49:44 +0900
Message-ID: <54ADC618.3060605@renesas.com>
References: <1420608947-6861-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <CAMuHMdUyJk+27BsGaZGh+TOqhA5qH4q_pL2hM=tp-Ktn=hkFnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdUyJk+27BsGaZGh+TOqhA5qH4q_pL2hM=tp-Ktn=hkFnw@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thanks for youre review.

(2015/01/07 17:42), Geert Uytterhoeven wrote:
> Hi Iwamatsu-san,
>
> On Wed, Jan 7, 2015 at 6:35 AM, Nobuhiro Iwamatsu
> <nobuhiro.iwamatsu.yj@renesas.com>  wrote:
>> TRSCER register is configured differently by SoCs. TRSCER of R-Car is
>> RINT8 bit only valid, other bits are reserved bits.
>> This removes access to TRSCER register reserve bit.
>>
>> Signed-off-by: Nobuhiro Iwamatsu<nobuhiro.iwamatsu.yj@renesas.com>
>> ---
>>   drivers/net/ethernet/renesas/sh_eth.c | 6 +++++-
>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index c29ba80..59ee457 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -1294,7 +1294,11 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
>>          /* Frame recv control (enable multiple-packets per rx irq) */
>>          sh_eth_write(ndev, RMCR_RNC, RMCR);
>>
>> -       sh_eth_write(ndev, DESC_I_RINT8 | DESC_I_RINT5 | DESC_I_TINT2, TRSCER);
>> +       if (mdp->cd->register_type == SH_ETH_REG_FAST_RCAR)
>
> This catches both the R-Car Gen1 and R-Car Gen2 cases.
> According to the datasheets, r8a7778/9 do have the other bits?
> Only R-Car Gen2 doesn't have them.

I see. I checked mistake.
I will resend about this patch.

>
>> +               sh_eth_write(ndev, DESC_I_RINT8, TRSCER);
>> +       else
>> +               sh_eth_write(ndev, DESC_I_RINT8 | DESC_I_RINT5 | DESC_I_TINT2,
>> +                            TRSCER);
>
> Gr{oetje,eeting}s,
>
>                          Geert
>
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
>
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                  -- Linus Torvalds

Best regards,
   Nobuhiro
