From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH wireless-2.6 11/12] Host AP: Fix PRISM2_IO_DEBUG
Date: Tue, 09 Nov 2004 02:29:52 -0500
Message-ID: <419071F0.6030602@pobox.com>
References: <20041108070156.GA1076@jm.kir.nu> <20041108071710.GL1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20041108071710.GL1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
>>From Mark Glines <mark@glines.org>:
> I just noticed PRISM2_IO_DEBUG doesn't work.  This patch gets it
> working again.  I checked the development CVS snapshot, looks like
> its still broken there.
> 
> jkm: in addition, fix the other PRISM2_IO_DEBUG function
> 
> Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>
> 
> 
> diff -Nru a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
> --- a/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-07 22:39:16 -08:00
> +++ b/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-07 22:39:16 -08:00
> @@ -1006,7 +1006,8 @@
>  static inline void prism2_io_debug_add(struct net_device *dev, int cmd,
>  				       int reg, int value)
>  {
> -	local_info_t *local = dev->priv;
> +	struct hostap_interface *iface = dev->priv;
> +	local_info_t *local = iface->local;
>  
>  	if (!local->io_debug_enabled)
>  		return;
> @@ -1023,7 +1024,8 @@
>  
>  static inline void prism2_io_debug_error(struct net_device *dev, int err)
>  {
> -	local_info_t *local = dev->priv;
> +	struct hostap_interface *iface = dev->priv;
> +	local_info_t *local = iface->local;
>  	unsigned long flags;

it is preferred to use netdev_priv() rather than directly referring to 
dev->priv.

	Jeff
