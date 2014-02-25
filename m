From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next v2 1/3] net: bcmgenet: drop checks on priv->phydev
Date: Tue, 25 Feb 2014 20:09:56 +0400
Message-ID: <530CC054.9020809@cogentembedded.com>
References: <1393289773-9473-1-git-send-email-f.fainelli@gmail.com> <1393289773-9473-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:58678 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbaBYQKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 11:10:02 -0500
Received: by mail-lb0-f174.google.com with SMTP id l4so3432761lbv.19
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 08:10:01 -0800 (PST)
In-Reply-To: <1393289773-9473-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-02-2014 4:56, Florian Fainelli wrote:

> Drop all the checks on priv->phydev since we will refuse probing the
> driver if we cannot attach to a PHY device. Drop all checks on
> priv->phydev. This also fixes some smatch issues reported by Dan
> Carpenter.

> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> - addressed Sergei's comment re-align phy_mac_interrupt and drop
>    useless parenthesis

>   drivers/net/ethernet/broadcom/genet/bcmgenet.c | 17 ++++++-----------
>   1 file changed, 6 insertions(+), 11 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 192069d..5856457 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
[...]
> @@ -1811,9 +1810,8 @@ static void bcmgenet_irq_task(struct work_struct *work)
>   	/* Link UP/DOWN event */
>   	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
>   		(priv->irq0_stat & (UMAC_IRQ_LINK_UP|UMAC_IRQ_LINK_DOWN))) {
> -		if (priv->phydev)
> -			phy_mac_interrupt(priv->phydev,
> -				(priv->irq0_stat & UMAC_IRQ_LINK_UP));
> +		phy_mac_interrupt(priv->phydev,
> +			priv->irq0_stat & UMAC_IRQ_LINK_UP);

    I still don't see this line aligned as needed, to start under 'priv->phydev'.

WBR, Sergei
