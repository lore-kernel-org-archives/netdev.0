From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 6/8] net: ethernet: annapurna: add wol helpers to
 the Alpine driver
Date: Fri, 3 Feb 2017 21:21:46 +0300
Message-ID: <08b62752-8bb2-4633-c44f-74eb585e7e52@cogentembedded.com>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
 <20170203181216.30214-7-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsahee@annapurnalabs.com, rshitrit@annapurnalabs.com,
        saeed@annapurnalabs.com, barak@annapurnalabs.com,
        talz@annapurnalabs.com, thomas.petazzoni@free-electrons.com,
        arnd@arndb.de
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33568 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdBCSVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:21:50 -0500
Received: by mail-lf0-f42.google.com with SMTP id x1so14537004lff.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 10:21:49 -0800 (PST)
In-Reply-To: <20170203181216.30214-7-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 02/03/2017 09:12 PM, Antoine Tenart wrote:

> Implement the get_wol() and set_wol() helpers in the Annapurna Labs
> Alpine Ethernet driver.
> ---
>  drivers/net/ethernet/annapurna/al_eth.c | 44 +++++++++++++++++++++++++++++++++
>  1 file changed, 44 insertions(+)
>
> diff --git a/drivers/net/ethernet/annapurna/al_eth.c b/drivers/net/ethernet/annapurna/al_eth.c
> index 8dd84f66b5d1..d06a75a49ce5 100644
> --- a/drivers/net/ethernet/annapurna/al_eth.c
> +++ b/drivers/net/ethernet/annapurna/al_eth.c
> @@ -2519,10 +2519,54 @@ static u32 al_eth_get_rxfh_indir_size(struct net_device *netdev)
>  	return AL_ETH_RX_RSS_TABLE_SIZE;
>  }
>
> +static void al_eth_get_wol(struct net_device *netdev,
> +			   struct ethtool_wolinfo *wol)
> +{
> +	struct al_eth_adapter *adapter = netdev_priv(netdev);
> +	struct phy_device *phydev;
> +
> +	wol->wolopts = adapter->wol;
> +
> +	if ((adapter) && (adapter->phy_exist) && (adapter->mdio_bus)) {

    Now that's somewhat stupid looking... does the whole driver use this "style"?

MBR, Sergei
