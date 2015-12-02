From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 08/26] net: add info struct for LAG changeupper
Date: Wed, 2 Dec 2015 11:59:59 +0100
Message-ID: <565ECF2F.7050500@cumulusnetworks.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-9-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34977 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbbLBLAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 06:00:02 -0500
Received: by wmuu63 with SMTP id u63so209576640wmu.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 03:00:01 -0800 (PST)
In-Reply-To: <1448977744-17930-9-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2015 02:48 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This struct will be shared by bonding and team to pass internal
> information to notifier listeners.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/netdevice.h | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a55be5b..7ea3e83 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2108,6 +2108,19 @@ struct pcpu_sw_netstats {
>  #define netdev_alloc_pcpu_stats(type)					\
>  	__netdev_alloc_pcpu_stats(type, GFP_KERNEL);
>  
> +enum netdev_lag_tx_type {
> +	NETDEV_LAG_TX_TYPE_UNKNOWN,
> +	NETDEV_LAG_TX_TYPE_RANDOM,
> +	NETDEV_LAG_TX_TYPE_BROADCAST,
> +	NETDEV_LAG_TX_TYPE_ROUNDROBIN,
> +	NETDEV_LAG_TX_TYPE_ACTIVEBACKUP,
> +	NETDEV_LAG_TX_TYPE_HASH,
> +};

There're 2 more modes supported by the bonding which aren't supported by team,
RLB and TLB. Since you've included _RANDOM, for completeness you can add
these, too.

> +
> +struct netdev_lag_upper_info {
> +	enum netdev_lag_tx_type tx_type;
> +};
> +
>  #include <linux/notifier.h>
>  
>  /* netdevice notifier chain. Please remember to update the rtnetlink
> 
