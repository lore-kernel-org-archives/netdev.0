From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] sfc: fix addr_list_lock spinlock use before init
Date: Tue, 16 Sep 2014 18:02:32 +0200
Message-ID: <54185F18.4020003@redhat.com>
References: <1410785727-659-1-git-send-email-nikolay@redhat.com> <alpine.LFD.2.03.1409161540490.25290@solarflare.com> <alpine.LFD.2.03.1409161654370.25290@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ben Hutchings <ben@decadent.org.uk>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032AbaIPQCo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 12:02:44 -0400
In-Reply-To: <alpine.LFD.2.03.1409161654370.25290@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/14 17:57, Edward Cree wrote:
> Reported by Nikolay Aleksandrov.  In efx_init_port() we call
>   efx_mac_reconfigure() to work around a Falcon/A1 limitation, and this calls
>   efx_{arch}_filter_sync_rx_mode(), which takes the addr_list_lock; but this
>   lock is uninitialised, because we haven't called register_netdevice() yet.
> So, in efx_farch_filter_sync_rx_mode(), check efx_dev_registered() before
>   doing anything else.
> The EF10 equivalent, efx_ef10_filter_sync_rx_mode(), already has the
>   corresponding check.
> ---
>   drivers/net/ethernet/sfc/farch.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
> index 0537381..6859437 100644
> --- a/drivers/net/ethernet/sfc/farch.c
> +++ b/drivers/net/ethernet/sfc/farch.c
> @@ -2933,6 +2933,9 @@ void efx_farch_filter_sync_rx_mode(struct efx_nic *efx)
>   	u32 crc;
>   	int bit;
>
> +	if (!efx_dev_registered(efx))
> +		return;
> +
>   	netif_addr_lock_bh(net_dev);
>
>   	efx->unicast_filter = !(net_dev->flags & IFF_PROMISC);
>

You should add a Signed-off-by, otherwise looks good to me.
FWIW, you can add my Tested-by as well.

Tested-by: Nikolay Aleksandrov <nikolay@redhat.com>
