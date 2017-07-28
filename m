From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH net] xgene: Don't fail probe, if there is no clk resource
 for SGMII interfaces
Date: Fri, 28 Jul 2017 11:40:30 -0700
Message-ID: <CAKh23FmRBqgc7Yi0ANhkUMk=NZteRuT3UbK1DffzdjYWDX5fbg@mail.gmail.com>
References: <20170713092144.31751508094@solo.franken.de> <22ee6284-7b23-7664-d6cf-23687f09a3be@redhat.com>
 <20170727213915.GA4902@alpha.franken.de> <1b3391f2-2fae-2a9a-719d-3f8358e39c71@redhat.com>
 <20170728142318.GA20368@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Laura Abbott <labbott@redhat.com>,
        Keyur Chudgar <kchudgar@apm.com>,
        Quan Nguyen <qnguyen@apm.com>, netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Tom Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728142318.GA20368@alpha.franken.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 7:23 AM, Tom Bogendoerfer
<tsbogend@alpha.franken.de> wrote:
> On Thu, Jul 27, 2017 at 03:39:58PM -0700, Laura Abbott wrote:
>> I don't know the intricacies of the Mustang hardware but external
>> aborts have been a symptom of missing clocks on other hardware.
>
> you are right, it's a missing clock. For SGMII ports the driver
> doesn't really use the clock source other then doing the one
> devm_clk_get(), but this is enough to get the clock going.
>
> Below patch fixes the crash and brings back the second SGMII port
> (even without a clock source in device tree, I guess it uses clock
> from first port).  From a correctness standpoint there should probably
> be a clk_prepare_enable(), if port is SGMII.
>
> Could you test the patch ? If it works, I'll submit it.
>
> Thomas.
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 86058a9f3417..1d307f2def2d 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -1785,9 +1785,9 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>
>         xgene_enet_gpiod_get(pdata);
>
> -       if (pdata->phy_mode != PHY_INTERFACE_MODE_SGMII) {
> -               pdata->clk = devm_clk_get(&pdev->dev, NULL);
> -               if (IS_ERR(pdata->clk)) {
> +       pdata->clk = devm_clk_get(&pdev->dev, NULL);
> +       if (IS_ERR(pdata->clk)) {
> +               if (pdata->phy_mode != PHY_INTERFACE_MODE_SGMII) {
>                         /* Abort if the clock is defined but couldn't be
>                          * retrived. Always abort if the clock is missing on
>                          * DT system as the driver can't cope with this case.
>
> --

Thanks for the patch.

Acked-by: Iyappan Subramanian <isubramanian@apm.com>

> Crap can work. Given enough thrust pigs will fly, but it's not necessarily a
> good idea.                                                [ RFC1925, 2.3 ]
