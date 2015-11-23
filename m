From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: stmmac: add a warning when aliases are not present in device tree
Date: Tue, 24 Nov 2015 01:35:38 +0200
Message-ID: <CAHp75VfGhk6HNAOQEePic=Ma2Hy4pE4cRXBHvFjaMFDrb6R4Mg@mail.gmail.com>
References: <20151123154648.GA16978@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: peppe.cavallaro@st.com, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jiri Kosina <trivial@kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:36095 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbbKWXfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 18:35:39 -0500
In-Reply-To: <20151123154648.GA16978@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 5:46 PM, Pavel Machek <pavel@ucw.cz> wrote:
>
>
> If aliases are not present in device tree, stmmac_platform.c will
> happily assign bus_id of 0 to all the ethernet interfaces, resulting
> in hard to debug problems.
>
> At least warn the user about the problem.
>
> Signed-off-by: Pavel Machek <pavel@denx.de>
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index f9b42f1..ee8aa26 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -161,8 +161,10 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>                 plat->max_speed = -1;
>
>         plat->bus_id = of_alias_get_id(np, "ethernet");
> -       if (plat->bus_id < 0)
> +       if (plat->bus_id < 0) {
> +               dev_warn(&pdev->dev, "no aliases for ethernet; multiple ethernets will break\n");

Spelling: will break what?

Perhaps "multiple ethernet support will be broken".


>                 plat->bus_id = 0;
> +       }
>
>         /* Default to phy auto-detection */
>         plat->phy_addr = -1;
>
> --
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko
