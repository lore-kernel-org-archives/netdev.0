From: Igor Gnatenko <i.gnatenko.brain@gmail.com>
Subject: Re: [PATCH RESEND net] stmmac: fix missing MODULE_LICENSE in stmmac_platform
Date: Sat, 1 Aug 2015 02:03:33 +0300
Message-ID: <CAFMg4WD4jUBVyXq4yxUwumxfWkrt+oPS5sL2RD5wMjV8+07z4Q@mail.gmail.com>
References: <CAFMg4WCm6rs6xMKPiKGmALc45+ne-xUzQgYHH7zOPotQ-iEqjg@mail.gmail.com>
	<1438362802-11929-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>,
	Maxime Ripard <maxime.ripard@anandra.org>
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:36531 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbbGaXDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 19:03:34 -0400
Received: by labiq1 with SMTP id iq1so18085742lab.3
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:03:33 -0700 (PDT)
In-Reply-To: <1438362802-11929-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just get's home. It works, thanks for quick fix!

On Fri, Jul 31, 2015 at 8:13 PM, Joachim Eastwood <manabian@gmail.com> wrote:
> Commit 50649ab14982 ("stmmac: drop driver from stmmac platform code")
> was a bit overzealous in removing code and dropped the MODULE_*
> macro's that are still needed since stmmac_platform can be a module.
> Fix this by putting the macro's remvoed in 50649ab14982 back.
>
> This fixes the following errors when used as a module:
>   stmmac_platform: module license 'unspecified' taints kernel.
>   Disabling lock debugging due to kernel taint
>   stmmac_platform: Unknown symbol devm_kmalloc (err 0)
>   stmmac_platform: Unknown symbol stmmac_suspend (err 0)
>   stmmac_platform: Unknown symbol platform_get_irq_byname (err 0)
>   stmmac_platform: Unknown symbol stmmac_dvr_remove (err 0)
>   stmmac_platform: Unknown symbol platform_get_resource (err 0)
>   stmmac_platform: Unknown symbol of_get_phy_mode (err 0)
>   stmmac_platform: Unknown symbol of_property_read_u32_array (err 0)
>   stmmac_platform: Unknown symbol of_alias_get_id (err 0)
>   stmmac_platform: Unknown symbol stmmac_resume (err 0)
>   stmmac_platform: Unknown symbol stmmac_dvr_probe (err 0)
>
> Fixes: 50649ab14982 ("stmmac: drop driver from stmmac platform code")
> Reported-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
Reported-and-tested-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
I think also lacks of reference tag.
Reference: https://bugzilla.kernel.org/show_bug.cgi?id=102141
> Signed-off-by: Joachim Eastwood <manabian@gmail.com>
> ---
> Hi,
>
> Sorry for the resend, I managed to screwed up Igor's email address
> in the previous one.
>
>
> An alternative solution could be to change CONFIG_STMMAC_PLATFORM
> into a bool, but I guess we want to keep things as modular as
> possible.
>
> Please test this Igor and report back. Thanks!
>
> CAFMg4WCm6rs6xMKPiKGmALc45+ne-xUzQgYHH7zOPotQ-iEqjg@mail.gmail.com
>
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index f3918c7e7eeb..bcdc8955c719 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -413,3 +413,7 @@ static int stmmac_pltfr_resume(struct device *dev)
>  SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops, stmmac_pltfr_suspend,
>                                        stmmac_pltfr_resume);
>  EXPORT_SYMBOL_GPL(stmmac_pltfr_pm_ops);
> +
> +MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet platform support");
> +MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
> +MODULE_LICENSE("GPL");
> --
> 1.8.0
>



-- 
-Igor Gnatenko
