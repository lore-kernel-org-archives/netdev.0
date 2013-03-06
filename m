From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: prevent div-by-zero panic when ring
 resizing uninitialized dev
Date: Wed, 06 Mar 2013 15:38:41 -0500 (EST)
Message-ID: <20130306.153841.784919874486534382.davem@davemloft.net>
References: <1362591984-16587-1-git-send-email-bhavesh@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, sbhatewara@vmware.com
To: bhavesh@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755012Ab3CFUio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:38:44 -0500
In-Reply-To: <1362591984-16587-1-git-send-email-bhavesh@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhavesh Davda <bhavesh@vmware.com>
Date: Wed,  6 Mar 2013 09:46:24 -0800

> Linux is free to call ethtool ops as soon as a netdev exists when probe
> finishes. However, we only allocate vmxnet3 tx/rx queues and initialize the
> rx_buf_per_pkt field in struct vmxnet3_adapter when the interface is
> opened (UP).
> 
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c     |    3 ++-
>  drivers/net/vmxnet3/vmxnet3_ethtool.c |    6 ++++++
>  drivers/net/vmxnet3/vmxnet3_int.h     |    4 ++--
>  3 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 4aad350..bfc5898 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -2922,7 +2922,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
>  				    (int)num_online_cpus());
>  	else
>  #endif
> -		num_rx_queues = 1;
> +	num_rx_queues = 1;

Why are you un-indenting this else branch?  Please don't do that.
