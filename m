From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH] phy: micrel: make phy_has_fixups attribute read correctly
Date: Thu, 26 Jun 2014 11:00:17 -0700
Message-ID: <CAGVrzcaN9KKW6vN5Xy775RTBD3ODpK95-o0V+pKDcCCxetPycA@mail.gmail.com>
References: <1403681075-16181-1-git-send-email-voice.shen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Bo Shen <voice.shen@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403681075-16181-1-git-send-email-voice.shen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

2014-06-25 0:24 GMT-07:00 Bo Shen <voice.shen@atmel.com>:
> If the fixups parameters get from dtb, it won't set has_fixups
> parameters, so when read phy_has_fixups attribute, it always
> present as 0.
> Add this patch to make phy_has_fixups attribute read correctly.

I am not entirely sure whether loading values from Device Tree should
be considered a PHY fixup per-se. They do override the hardware reset
default values, but I am not sure if we should consider that as a
fixup.

Assuming that you need to troubleshoot a given system, one of the
first things you will surely ask for is the DTS used by that platform,
and in that case you can quickly check whether the PHY default
settings are changed, right?

>
> Signed-off-by: Bo Shen <voice.shen@atmel.com>
> ---
>  drivers/net/phy/micrel.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index bc7c7d2..c384922 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -237,6 +237,8 @@ static int ksz9021_load_values_from_of(struct phy_device *phydev,
>
>         if (!matches)
>                 return 0;
> +       else
> +               phydev->has_fixups = true;

There is no need for the else here

>
>         if (matches < 4)
>                 newval = kszphy_extended_read(phydev, reg);
> @@ -330,6 +332,8 @@ static int ksz9031_of_load_skew_values(struct phy_device *phydev,
>
>         if (!matches)
>                 return 0;
> +       else
> +               phydev->has_fixups = true;

Same here

>
>         if (matches < numfields)
>                 newval = ksz9031_extended_read(phydev, OP_DATA, 2, reg);
> --
> 1.8.5.2
>



-- 
Florian
