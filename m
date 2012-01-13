From: David Vrabel <dvrabel@cantab.net>
Subject: Re: [Xen-devel] [RFC PATCH 4/6] netback: add module get/put operations
 along with vif connect/disconnect.
Date: Fri, 13 Jan 2012 18:44:25 +0000
Message-ID: <4F107B89.6000004@cantab.net>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com> <1326473949-22389-5-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56742 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614Ab2AMSo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 13:44:28 -0500
Received: by yhnn56 with SMTP id n56so409273yhn.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 10:44:28 -0800 (PST)
In-Reply-To: <1326473949-22389-5-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/12 16:59, Wei Liu wrote:
> If there is vif running and user unloads netback, it will certainly
> cause problems.

Is this necessary?  As part of module unload netback_remove() will be
called and this will clean everything correctly, yes?

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 93cb212..3126028 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -323,6 +323,8 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  	if (vif->irq)
>  		return 0;
>  
> +	__module_get(THIS_MODULE);
> +
>  	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
>  	if (err < 0)
>  		goto err;
> @@ -405,4 +407,6 @@ void xenvif_disconnect(struct xenvif *vif)
>  	xen_netbk_unmap_frontend_rings(vif);
>  
>  	free_netdev(vif->dev);
> +
> +	module_put(THIS_MODULE);
>  }
