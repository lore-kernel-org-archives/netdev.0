From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [PATCH -next] vmxnet3: fail when try to setup unsupported
 features
Date: Mon, 28 Jun 2010 10:45:57 -0700
Message-ID: <89E2752CFA8EC044846EB8499819134102BCC3C10A@EXCH-MBX-4.vmware.com>
References: <20100628112942.0c919746@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amerigo Wang <amwang@redhat.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:31150 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753110Ab0F1RrS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 13:47:18 -0400
In-Reply-To: <20100628112942.0c919746@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stanislaw Gruszka [mailto:sgruszka@redhat.com]
> Sent: Monday, June 28, 2010 2:30 AM
> To: netdev@vger.kernel.org
> Cc: Amerigo Wang; Shreyas Bhatewara
> Subject: [PATCH -next] vmxnet3: fail when try to setup unsupported
> features
> 
> Return EOPNOTSUPP in ethtool_ops->set_flags.
> 
> Fix coding style while at it.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_ethtool.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> index 3935c44..8a71a21 100644
> --- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> @@ -276,16 +276,21 @@ vmxnet3_get_strings(struct net_device *netdev,
> u32 stringset, u8 *buf)
>  }
> 
>  static u32
> -vmxnet3_get_flags(struct net_device *netdev) {
> +vmxnet3_get_flags(struct net_device *netdev)
> +{
>  	return netdev->features;
>  }
> 
>  static int
> -vmxnet3_set_flags(struct net_device *netdev, u32 data) {
> +vmxnet3_set_flags(struct net_device *netdev, u32 data)
> +{
>  	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
>  	u8 lro_requested = (data & ETH_FLAG_LRO) == 0 ? 0 : 1;
>  	u8 lro_present = (netdev->features & NETIF_F_LRO) == 0 ? 0 : 1;
> 
> +	if (data & ~ETH_FLAG_LRO)
> +		return -EOPNOTSUPP;
> +
>  	if (lro_requested ^ lro_present) {
>  		/* toggle the LRO feature*/
>  		netdev->features ^= NETIF_F_LRO;
> --
> 1.5.5.6


Does not make sense to me. Switching LRO on/off is supported from the driver, why should the function return -EOPNOTSUPP ?

->Shreyas
