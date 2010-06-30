From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH net-next-2.6 3/3] vmxnet3: Remove incorrect
 implementation of ethtool_ops::get_flags()
Date: Wed, 30 Jun 2010 08:44:34 -0700
Message-ID: <8B1F619C9F5F454E81D90D3C161698D703362510AE@EXCH-MBX-3.vmware.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
 <1277902060.2082.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "VMware, Inc." <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:10383 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754949Ab0F3Pwa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 11:52:30 -0400
In-Reply-To: <1277902060.2082.13.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for fixing this, Ben! Had to look at ethtool-2.6.34 src to convince myself of the correctness. Looks good to me. 

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

ps: I do wonder, however, why not always use ethtool_op_get_flags for all drivers, and mask whatever is returned by the driver specific dev->ethtool_ops->get_flags with flags_dup_features instead of this approach?


- Bhavesh
 
Bhavesh P. Davda

> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-
> bounces@vmware.com] On Behalf Of Ben Hutchings
> Sent: Wednesday, June 30, 2010 5:48 AM
> To: David Miller
> Cc: VMware, Inc.; netdev@vger.kernel.org
> Subject: [Pv-drivers] [PATCH net-next-2.6 3/3] vmxnet3: Remove
> incorrect implementation of ethtool_ops::get_flags()
> 
> Only some netdev feature flags correspond directly to ethtool feature
> flags.  ethtool_op_get_flags() does the right thing.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_ethtool.c |    8 +-------
>  1 files changed, 1 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> index 8a71a21..de1ba14 100644
> --- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> @@ -275,12 +275,6 @@ vmxnet3_get_strings(struct net_device *netdev, u32
> stringset, u8 *buf)
>  	}
>  }
> 
> -static u32
> -vmxnet3_get_flags(struct net_device *netdev)
> -{
> -	return netdev->features;
> -}
> -
>  static int
>  vmxnet3_set_flags(struct net_device *netdev, u32 data)
>  {
> @@ -559,7 +553,7 @@ static struct ethtool_ops vmxnet3_ethtool_ops = {
>  	.get_tso           = ethtool_op_get_tso,
>  	.set_tso           = ethtool_op_set_tso,
>  	.get_strings       = vmxnet3_get_strings,
> -	.get_flags	   = vmxnet3_get_flags,
> +	.get_flags	   = ethtool_op_get_flags,
>  	.set_flags	   = vmxnet3_set_flags,
>  	.get_sset_count	   = vmxnet3_get_sset_count,
>  	.get_ethtool_stats = vmxnet3_get_ethtool_stats,
> --
> 1.6.2.5
> 
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
