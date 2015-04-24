From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: netcp: remove call to netif_carrier_(on/off) for
 MAC to Phy interface
Date: Fri, 24 Apr 2015 16:33:23 +0300
Message-ID: <553A4623.2070802@cogentembedded.com>
References: <1429816627-24337-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Murali Karicheri <m-karicheri2@ti.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35723 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233AbbDXNd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 09:33:26 -0400
Received: by lbbuc2 with SMTP id uc2so36541136lbb.2
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 06:33:25 -0700 (PDT)
In-Reply-To: <1429816627-24337-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/23/2015 10:17 PM, Murali Karicheri wrote:

> Currently when interface type is MAC to Phy, netif_carrier_(on/off)
> is called which is not needed as Phy lib already updates the carrier
> status to net stack. This is needed only for other interface types

> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> ---
>   drivers/net/ethernet/ti/netcp_ethss.c |    8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
> index 2bef655..0a1ef2e 100644
> --- a/drivers/net/ethernet/ti/netcp_ethss.c
> +++ b/drivers/net/ethernet/ti/netcp_ethss.c
> @@ -1765,7 +1765,9 @@ static void netcp_ethss_link_state_action(struct gbe_priv *gbe_dev,
>   				     ALE_PORT_STATE,
>   				     ALE_PORT_STATE_FORWARD);
>
> -		if (ndev && slave->open)
> +		if (ndev && slave->open &&
> +		    ((slave->link_interface != SGMII_LINK_MAC_PHY) &&
> +		    (slave->link_interface != XGMII_LINK_MAC_PHY)))

    You don't need extra parens around &&.

>   			netif_carrier_on(ndev);
>   	} else {
>   		writel(mac_control, GBE_REG_ADDR(slave, emac_regs,
> @@ -1773,7 +1775,9 @@ static void netcp_ethss_link_state_action(struct gbe_priv *gbe_dev,
>   		cpsw_ale_control_set(gbe_dev->ale, slave->port_num,
>   				     ALE_PORT_STATE,
>   				     ALE_PORT_STATE_DISABLE);
> -		if (ndev)
> +		if (ndev &&
> +		    ((slave->link_interface != SGMII_LINK_MAC_PHY) &&
> +		    (slave->link_interface != XGMII_LINK_MAC_PHY)))

    Likewise.

WBR, Sergei
