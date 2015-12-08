From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: vsock: select CONFIG_VHOST
Date: Tue, 8 Dec 2015 18:09:44 +0200
Message-ID: <20151208180529-mutt-send-email-mst@redhat.com>
References: <36261336.7BBY96nNaM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Asias He <asias@redhat.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <36261336.7BBY96nNaM@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 08, 2015 at 04:46:08PM +0100, Arnd Bergmann wrote:
> When building the new vsock code without vhost, we get a build error:
> 
> drivers/built-in.o: In function `vhost_vsock_flush':
> :(.text+0x24d29c): undefined reference to `vhost_poll_flush'
> 
> This adds an explicit 'select' like we have for the other vhost
> drivers.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

This will need to be done eventually, so

Acked-by: Michael S. Tsirkin <mst@redhat.com>

but I really think the right thing for now is to revert current vsock
code, or disable building it unconditionally.  Stefan, could you please
send a patch like this?

> ---
>  drivers/vhost/Kconfig.vsock | 2 ++
>  1 file changed, 2 insertions(+)
> 
> The patch causing the problem is currently in net-next, so the fix should be
> applied on top of that.
> 
> diff --git a/drivers/vhost/Kconfig.vsock b/drivers/vhost/Kconfig.vsock
> index 3491865d3eb9..bfb9edc4b5d6 100644
> --- a/drivers/vhost/Kconfig.vsock
> +++ b/drivers/vhost/Kconfig.vsock
> @@ -2,6 +2,8 @@ config VHOST_VSOCK
>  	tristate "vhost virtio-vsock driver"
>  	depends on VSOCKETS && EVENTFD
>  	select VIRTIO_VSOCKETS_COMMON
> +	select VHOST
> +	select VHOST_RING
>  	default n
>  	---help---
>  	Say M here to enable the vhost-vsock for virtio-vsock guests
> -- 
> 2.1.0.rc2
> 
