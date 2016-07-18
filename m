From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] net: ethernet: marvell: pxa168_eth: use phydev from
 struct net_device
Date: Mon, 18 Jul 2016 13:14:56 +0300
Message-ID: <f1706f95-8135-d8ec-c65f-edc7d2d63e5e@cogentembedded.com>
References: <1468791046-19567-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net,
	jszhang@marvell.com, mugunthanvnm@ti.com, a@unstable.cc,
	fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:33016 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbcGRKO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 06:14:59 -0400
Received: by mail-lf0-f52.google.com with SMTP id b199so128566824lfe.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 03:14:59 -0700 (PDT)
In-Reply-To: <1468791046-19567-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/18/2016 12:30 AM, Philippe Reynes wrote:

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/ethernet/marvell/pxa168_eth.c |   36 +++++++++++++----------------
>  1 files changed, 16 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
> index 54d5154..d466326 100644
> --- a/drivers/net/ethernet/marvell/pxa168_eth.c
> +++ b/drivers/net/ethernet/marvell/pxa168_eth.c
[...]
> @@ -973,16 +972,17 @@ static int pxa168_init_phy(struct net_device *dev)
>  {
>  	struct pxa168_eth_private *pep = netdev_priv(dev);
>  	struct ethtool_cmd cmd;
> +	struct phy_device *phy = NULL;

   Initializer not really needed.

>  	int err;
>
> -	if (pep->phy)
> +	if (dev->phydev)
>  		return 0;
>
> -	pep->phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
> -	if (IS_ERR(pep->phy))
> -		return PTR_ERR(pep->phy);
> +	phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
> +	if (IS_ERR(phy))
> +		return PTR_ERR(phy);
>
> -	err = phy_connect_direct(dev, pep->phy, pxa168_eth_adjust_link,
> +	err = phy_connect_direct(dev, phy, pxa168_eth_adjust_link,
>  				 pep->phy_intf);
>  	if (err)
>  		return err;

    Hm, where do you assign 'dev->phydev'?

[...]

MBR, Sergei
