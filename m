From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Thu, 16 Jul 2015 16:25:58 -0700
Message-ID: <55A83D86.2030505@gmail.com>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A7C49E.2020803@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/07/15 07:50, Stas Sergeev wrote:
> 
> Currently fixed_phy driver recognizes only the link-up state.
> This simple patch adds an implementation of link-down state.
> It fixes the status registers when link is down, and also allows
> to register the fixed-phy with link down without specifying the speed.

This patch still breaks my setups here, e.g: drivers/net/dsa/bcm_sf2.c,
but I will look into it.

Do we really need this for now for your two other patches to work
properly, or is it just nicer to have?

> 
> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
> 
> CC: Florian Fainelli <f.fainelli@gmail.com>
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> ---
>  drivers/net/phy/fixed_phy.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
> index 1960b46..479b93f 100644
> --- a/drivers/net/phy/fixed_phy.c
> +++ b/drivers/net/phy/fixed_phy.c
> @@ -52,6 +52,10 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
>  	u16 lpagb = 0;
>  	u16 lpa = 0;
> 
> +	if (!fp->status.link)
> +		goto done;
> +	bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
> +
>  	if (fp->status.duplex) {
>  		bmcr |= BMCR_FULLDPLX;
> 
> @@ -96,15 +100,13 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
>  		}
>  	}
> 
> -	if (fp->status.link)
> -		bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
> -
>  	if (fp->status.pause)
>  		lpa |= LPA_PAUSE_CAP;
> 
>  	if (fp->status.asym_pause)
>  		lpa |= LPA_PAUSE_ASYM;
> 
> +done:
>  	fp->regs[MII_PHYSID1] = 0;
>  	fp->regs[MII_PHYSID2] = 0;
> 


-- 
Florian
