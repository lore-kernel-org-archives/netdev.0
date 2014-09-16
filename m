From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: fix addr_list_lock spinlock use before init
Date: Tue, 16 Sep 2014 16:33:57 -0400 (EDT)
Message-ID: <20140916.163357.1799289058951971945.davem@davemloft.net>
References: <alpine.LFD.2.03.1409161654370.25290@solarflare.com>
	<54185F18.4020003@redhat.com>
	<alpine.LFD.2.03.1409161704180.25290@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, ben@decadent.org.uk,
	sshah@solarflare.com, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbaIPUd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:33:59 -0400
In-Reply-To: <alpine.LFD.2.03.1409161704180.25290@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 16 Sep 2014 17:05:21 +0100

> Reported by Nikolay Aleksandrov.  In efx_init_port() we call
>  efx_mac_reconfigure() to work around a Falcon/A1 limitation, and this calls
>  efx_{arch}_filter_sync_rx_mode(), which takes the addr_list_lock; but this
>  lock is uninitialised, because we haven't called register_netdevice() yet.
> So, in efx_farch_filter_sync_rx_mode(), check efx_dev_registered() before
>  doing anything else.
> The EF10 equivalent, efx_ef10_filter_sync_rx_mode(), already has the
>  corresponding check.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> Tested-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied, thanks.
