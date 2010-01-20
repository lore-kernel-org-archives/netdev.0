From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] vhost: fix TUN=m VHOST_NET=y
Date: Wed, 20 Jan 2010 08:49:10 -0800
Message-ID: <20100120084910.a869aca8.randy.dunlap@oracle.com>
References: <20100120113037.GA9182@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:47208 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349Ab0ATQtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 11:49:49 -0500
In-Reply-To: <20100120113037.GA9182@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010 13:30:38 +0200 Michael S. Tsirkin wrote:

> drivers/built-in.o: In function `get_tun_socket':
>     net.c:(.text+0x15436e): undefined reference to `tun_get_socket'
> 
> If tun is a module, vhost must be a module, too.
> If tun is built-in or disabled, vhost can be built-in.
> 
> Note: TUN || !TUN might look a bit strange until you realize
> that boolean logic rules do not apply for tristate variables.
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
> 
> The above was already applied by Rusty, but got lost.
> The patch is on top of net-next.
> 
>  drivers/vhost/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/vhost/Kconfig b/drivers/vhost/Kconfig
> index 9f409f4..9e93553 100644
> --- a/drivers/vhost/Kconfig
> +++ b/drivers/vhost/Kconfig
> @@ -1,6 +1,6 @@
>  config VHOST_NET
>  	tristate "Host kernel accelerator for virtio net (EXPERIMENTAL)"
> -	depends on NET && EVENTFD && EXPERIMENTAL
> +	depends on NET && EVENTFD && (TUN || !TUN) && EXPERIMENTAL
>  	---help---
>  	  This kernel module can be loaded in host kernel to accelerate
>  	  guest networking with virtio_net. Not to be confused with virtio_net
> -- 
> 1.6.6.144.g5c3af


---
~Randy
