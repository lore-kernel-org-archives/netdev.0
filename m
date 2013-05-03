From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Add support for netconsole driver used on bridge device
 with VIF attached
Date: Fri, 3 May 2013 10:11:10 +0100
Message-ID: <1367572270.28742.44.camel@zakaz.uk.xensource.com>
References: <1367409301.3301.21.camel@yuval-pc.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge <bridge@lists.linux-foundation.org>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:16229 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762733Ab3ECJLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 05:11:13 -0400
In-Reply-To: <1367409301.3301.21.camel@yuval-pc.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 12:55 +0100, Yuval Shaia wrote:
[... snip regurgitation of the thread...]
> 0001-Add-support-for-netconsole-driver-used-on-bridge-dev.patch
> 0 2001
> From: Yuval <yuval.shaia@oracle.com>
> Date: Tue, 8 Jan 2013 10:08:45 +0200
> Subject: [PATCH] Add support for netconsole driver used on bridge device with
>  VIF attached

Sorry, but this is not what I was asking for.

Please submit with a coherent changelog based on (i.e. digested from)
the previous discussion which explains why this change is necessary
including the background of why it is being made in this way and the
interaction with the bridging layer. I wasn't asking you to just cut and
paste that discussion and prepend it to the commit like that.

The key point is that we don't think that doing netconsole from dom0 to
a domU on the same host is a useful configuration or something which is
especially desirable to support but that because of how the bridge
handles netconsole netback needs to expose this hook in order that
netconsole can be enabled via a physical device on the same bridge to a
netserver elsewhere.

> 
> Signed-off-by: Yuval <yuval.shaia@oracle.com>
> ---
>  drivers/net/xen-netback/interface.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/interface.c \
> b/drivers/net/xen-netback/interface.c index 601ae2a..10751f5 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -179,6 +179,13 @@ static u32 xenvif_fix_features(struct net_device *dev, u32 \
> features)  return features;
>  }
>  
> +static void xenvif_poll_controller(struct net_device *dev)
> +{
> +	disable_irq(dev->irq);
> +	xenvif_interrupt(dev->irq, dev);
> +	enable_irq(dev->irq);
> +}
> +
>  static const struct xenvif_stat {
>  	char name[ETH_GSTRING_LEN];
>  	u16 offset;
> @@ -237,6 +244,7 @@ static const struct net_device_ops xenvif_netdev_ops = {
>  	.ndo_stop	= xenvif_close,
>  	.ndo_change_mtu	= xenvif_change_mtu,
>  	.ndo_fix_features = xenvif_fix_features,
> +	.ndo_poll_controller = xenvif_poll_controller,
>  };
>  
>  struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
