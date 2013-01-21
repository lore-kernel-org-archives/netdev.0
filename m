From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Add support for netconsole driver used on bridge device
 with, VIF attached
Date: Mon, 21 Jan 2013 16:40:23 +0000
Message-ID: <1358786423.3279.249.camel@zakaz.uk.xensource.com>
References: <50FD6E17.1010309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:60572 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052Ab3AUQk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:40:26 -0500
In-Reply-To: <50FD6E17.1010309@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-21 at 16:34 +0000, yuval.shaia@oracle.com wrote:
> When starting a VM which has virtual interface attached to the same 
> bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is 
> used for netconsole the
> following message appears (after about 60 seconds) and VM creation 
> operation fails.
>       Error: Device 0 (vif) could not be connected. Hotplug scripts not 
> working.

I'm not sure how this can relate netconsole since this happens before
the guest even runs, doesn't it?

> Note:
> When trying to do the opposite, i.e. first create VM and then run
> netconsole we got the error #524 - vif2.0 doesn't support polling,
> aborting.
> 
> The following patch (to latest kernel) fix this bug by adding 
> implementation to ndo_poll_controller.

Surely this is needed in netfront not netback?

BT, you patch is whitespace damanged, please see
Documentation/SubmittingPatches and Documentation/email-clients.txt for
tips. Please also run checkpatch.pl.

Ian.

> 00
> 01-Add-support-for-netconsole-driver-used-on-bridge-dev.patch
> 0 2001
> From: Yuval <yuval.shaia@oracle.com>
> Date: Tue, 8 Jan 2013 10:08:45 +0200
> Subject: [PATCH] Add support for netconsole driver used on bridge device 
> with
>   VIF attached
> 
> Signed-off-by: Yuval <yuval.shaia@oracle.com>
> ---
>   drivers/net/xen-netback/interface.c |    8 ++++++++
>   1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/interface.c 
> b/drivers/net/xen-netback/interface.c
> index 601ae2a..10751f5 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -179,6 +179,13 @@ static u32 xenvif_fix_features(struct net_device 
> *dev, u32 features)
>       return features;
>   }
> 
> +static void xenvif_poll_controller(struct net_device *dev)
> +{
> +    disable_irq(dev->irq);
> +    xenvif_interrupt(dev->irq, dev);
> +    enable_irq(dev->irq);
> +}
> +
>   static const struct xenvif_stat {
>       char name[ETH_GSTRING_LEN];
>       u16 offset;
> @@ -237,6 +244,7 @@ static const struct net_device_ops xenvif_netdev_ops = {
>       .ndo_stop    = xenvif_close,
>       .ndo_change_mtu    = xenvif_change_mtu,
>       .ndo_fix_features = xenvif_fix_features,
> +    .ndo_poll_controller = xenvif_poll_controller,
>   };
> 
>   struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
