From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] stmmac: Add vlan rx for better GRO performance.
Date: Tue, 14 Jan 2014 22:14:09 +0300
Message-ID: <52D58C81.802@cogentembedded.com>
References: <1389720846-6543-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com
To: Vince Bridgers <vbridgers2013@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:61161 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbaANSOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 13:14:08 -0500
Received: by mail-lb0-f173.google.com with SMTP id y6so4782977lbh.32
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 10:14:07 -0800 (PST)
In-Reply-To: <1389720846-6543-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/14/2014 08:34 PM, Vince Bridgers wrote:

> GRO requires VLANs to be removed before aggregation can occur.
> The Synopsys EMAC does not strip VLAN tags so this must be
> done by the driver.

> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   18 ++++++++++++++++++
>   1 file changed, 18 insertions(+)

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index b8e3a4c..e3ff84e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1951,6 +1951,22 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>   	return NETDEV_TX_OK;
>   }
>
> +static inline void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
> +{
> +	struct ethhdr *ehdr;
> +	u16 vlanid;

    Empty line after declarations wouldn't hurt.

> +	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) ==
> +		NETIF_F_HW_VLAN_CTAG_RX &&

    Line should start right below the second paren on the previousl line.

> +		!__vlan_get_tag(skb, &vlanid)) {

    This one too.

WBR, Sergei
