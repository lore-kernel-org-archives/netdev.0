From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next] enable virtio_net to return bus_info in
 ethtool -i consistent with emulated NICs
Date: Mon, 14 Nov 2011 22:30:00 +0000
Message-ID: <1321309800.2827.22.camel@bwh-desktop>
References: <20111114215241.5B8BF2900307@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Rusty Russell <rusty@rustcorp.com.au>,
	Michael Tsirkin <mst@redhat.com>,
	<virtualization@lists.linux-foundation.org>
To: Rick Jones <raj@tardy.cup.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53481 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab1KNWaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 17:30:07 -0500
In-Reply-To: <20111114215241.5B8BF2900307@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-14 at 13:52 -0800, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> Add a new .bus_name to virtio_config_ops then modify virtio_net to 
> call through to it in an ethtool .get_drvinfo routine to report
> bus_info in ethtool -i output which is consistent with other
> emulated NICs and the output of lspci.  
[...]
> diff --git a/drivers/lguest/lguest_device.c b/drivers/lguest/lguest_device.c
> index 0dc30ff..3724d45 100644
> --- a/drivers/lguest/lguest_device.c
> +++ b/drivers/lguest/lguest_device.c
> @@ -381,6 +381,11 @@ error:
>  	return PTR_ERR(vqs[i]);
>  }
>  
> +static const char *lg_bus_name(struct virtio_device *vdev)
> +{
> +	return "Not Implemented";
> +}
[...]
> +static const char *kvm_bus_name(struct virtio_device *vdev)
> +{
> +	return "Not Implemented";
> +}
[...]

Please use the existing 'not implemented' value, which is the empty
string.   If you think ethtool should print some helpful message instead
of an empty string, please submit a patch for ethtool.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
