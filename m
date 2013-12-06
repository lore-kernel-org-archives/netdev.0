From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 7/9] net: pxa168_eth: use phy_init_hw for PHY reset
Date: Thu, 5 Dec 2013 17:06:06 -0800
Message-ID: <CAGVrzcZVTHE4v4ckPqY3QcAWOffTmME+2vQX5PH3toggOE9fkg@mail.gmail.com>
References: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com> <1386291317-1202-8-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Andy Fleming <afleming@gmail.com>,
	Kyle Moffett <kyle@moffetthome.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:39045 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab3LFBGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:06:47 -0500
Received: by mail-pb0-f42.google.com with SMTP id uo5so38479pbc.15
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 17:06:47 -0800 (PST)
In-Reply-To: <1386291317-1202-8-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/5 Florian Fainelli <f.fainelli@gmail.com>:
> Instead of open-coding a PHY reset through the MII BMCR register, use
> phy_init_hw() which does this for us and ensures that PHY device fixups
> are also applied.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/marvell/pxa168_eth.c | 19 +------------------
>  1 file changed, 1 insertion(+), 18 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
> index fff6246..b3642a0 100644
> --- a/drivers/net/ethernet/marvell/pxa168_eth.c
> +++ b/drivers/net/ethernet/marvell/pxa168_eth.c
> @@ -321,23 +321,6 @@ static void ethernet_phy_set_addr(struct pxa168_eth_private *pep, int phy_addr)
>         wrl(pep, PHY_ADDRESS, reg_data);
>  }
>
> -static void ethernet_phy_reset(struct pxa168_eth_private *pep)
> -{
> -       int data;
> -
> -       data = phy_read(pep->phy, MII_BMCR);
> -       if (data < 0)
> -               return;
> -
> -       data |= BMCR_RESET;
> -       if (phy_write(pep->phy, MII_BMCR, data) < 0)
> -               return;
> -
> -       do {
> -               data = phy_read(pep->phy, MII_BMCR);
> -       } while (data >= 0 && data & BMCR_RESET);
> -}

I forgot a reference to ethernet_phy_reset() somewhere later in the
driver. Will wait for comments until I issue a respin of these
patches.
-- 
Florian
