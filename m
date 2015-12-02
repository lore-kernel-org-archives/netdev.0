From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 10/26] bonding: fill-up LAG changeupper info
 struct and pass it along
Date: Wed, 2 Dec 2015 12:00:47 +0100
Message-ID: <565ECF5F.3060002@cumulusnetworks.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34684 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977AbbLBLAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 06:00:51 -0500
Received: by wmvv187 with SMTP id v187so248940773wmv.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 03:00:50 -0800 (PST)
In-Reply-To: <1448977744-17930-11-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2015 02:48 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Initialize netdev_lag_upper_info structure by TX type according to
> current bonding mode and pass it along via netdev_master_upper_dev_link.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/bonding/bond_main.c | 43 +++++++++++++++++++++++++++--------------
>  1 file changed, 29 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index fa3ed1d..8747746 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1198,26 +1198,41 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>  	return ret;
>  }
>  
> -static int bond_master_upper_dev_link(struct net_device *bond_dev,
> -				      struct net_device *slave_dev,
> -				      struct slave *slave)
> +static enum netdev_lag_tx_type bond_lag_tx_type(struct bonding *bond)
>  {
> +	switch (BOND_MODE(bond)) {
> +	case BOND_MODE_ROUNDROBIN:
> +		return NETDEV_LAG_TX_TYPE_ROUNDROBIN;
> +	case BOND_MODE_ACTIVEBACKUP:
> +		return NETDEV_LAG_TX_TYPE_ACTIVEBACKUP;
> +	case BOND_MODE_XOR:
> +	case BOND_MODE_8023AD:
> +		return NETDEV_LAG_TX_TYPE_HASH;
> +	default:
> +		return NETDEV_LAG_TX_TYPE_UNKNOWN;
> +	}
> +}

Bonding also has the broadcast mode (NETDEV_LAG_TX_BROADCAST).

> +
[snip]
