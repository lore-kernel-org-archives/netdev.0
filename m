From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] VSOCK: mark virtio_transport.ko experimental
Date: Fri, 4 Dec 2015 15:34:32 +0200
Message-ID: <20151204152942-mutt-send-email-mst@redhat.com>
References: <1449200958-18810-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34351 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbbLDNef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 08:34:35 -0500
Content-Disposition: inline
In-Reply-To: <1449200958-18810-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2015 at 11:49:18AM +0800, Stefan Hajnoczi wrote:
> Be explicit that the virtio_transport.ko code implements a draft virtio
> specification that is still subject to change.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> If you'd rather wait until the device specification has been finalized, feel
> free to revert the virtio-vsock code for now.  Apologies for not mentioning the
> status in the Kconfig earlier.
> 
>  net/vmw_vsock/Kconfig | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
> index 74e0bc8..d8be850 100644
> --- a/net/vmw_vsock/Kconfig
> +++ b/net/vmw_vsock/Kconfig
> @@ -28,12 +28,17 @@ config VMWARE_VMCI_VSOCKETS
>  	  will be called vmw_vsock_vmci_transport. If unsure, say N.
>  
>  config VIRTIO_VSOCKETS
> -	tristate "virtio transport for Virtual Sockets"
> +	tristate "virtio transport for Virtual Sockets (Experimental)"
>  	depends on VSOCKETS && VIRTIO
>  	select VIRTIO_VSOCKETS_COMMON
> +	default n
>  	help
>  	  This module implements a virtio transport for Virtual Sockets.
>  
> +	  This feature is based on a draft of the virtio-vsock device
> +	  specification that is still subject to change.  It can be used
> +	  to begin developing applications that use Virtual Sockets.
> +
>  	  Enable this transport if your Virtual Machine runs on Qemu/KVM.
>  
>  	  To compile this driver as a module, choose M here: the module

I'm pretty sure this alone is not enough.  I think depending on an entry
under drivers/staging is necessary. The issue is userspace depending on
the interface, not kernel code itself being unstable.  We can create
drivers/staging/virtio for this purpose, even if it's just to hold the
Kconfig entry.  And I'd rather add STAGING within the KConfig names too,
so people enabling it don't get a surpise when their userspace stops
working.

But yes, revert would be cleaner and easier than all this temporary
work.

If you agree, could you send a patch to do one of these two things pls?

> -- 
> 2.5.0
