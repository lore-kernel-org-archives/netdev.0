From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 1/3] net: bcmgenet: drop checks on priv->phydev
Date: Fri, 21 Feb 2014 02:54:05 +0300
Message-ID: <5306959D.5070101@cogentembedded.com>
References: <1392929631-7685-1-git-send-email-f.fainelli@gmail.com> <1392929631-7685-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:64510 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbaBTWyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 17:54:04 -0500
Received: by mail-lb0-f179.google.com with SMTP id l4so1785220lbv.38
        for <netdev@vger.kernel.org>; Thu, 20 Feb 2014 14:54:02 -0800 (PST)
In-Reply-To: <1392929631-7685-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/20/2014 11:53 PM, Florian Fainelli wrote:

> Drop all the checks on priv->phydev since we will refuse probing the
> driver if we cannot attach to a PHY device. Drop all checks on
> priv->phydev. This also fixes some smatch issues reported by Dan
> Carpenter where smatch would complain that a pointer is not always
> checked correctly.

> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/genet/bcmgenet.c | 15 +++++----------
>   1 file changed, 5 insertions(+), 10 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 0ebc297..8af5f07 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
[...]
> @@ -1811,8 +1810,7 @@ static void bcmgenet_irq_task(struct work_struct *work)
>   	/* Link UP/DOWN event */
>   	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
>   		(priv->irq0_stat & (UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN))) {
> -		if (priv->phydev)
> -			phy_mac_interrupt(priv->phydev,
> +		phy_mac_interrupt(priv->phydev,
>   				(priv->irq0_stat & UMAC_IRQ_LINK_UP));

    Should probably realign this line (although it wasn't correctly aligned 
before). Also () are not needed around &.

WBR, Sergei
