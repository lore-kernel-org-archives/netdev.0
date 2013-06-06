From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH 8/8] macvtap: enable multiqueue flag
Date: Thu, 6 Jun 2013 14:05:50 +0300
Message-ID: <20130606110550.GE8626@redhat.com>
References: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
 <1370512480-14272-9-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370512480-14272-9-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 06, 2013 at 05:54:40PM +0800, Jason Wang wrote:
> To notify the userspace about our capability of multiqueue.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index d2d1d55..992151c 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -31,10 +31,6 @@
>   * macvtap_proto is used to allocate queues through the sock allocation
>   * mechanism.
>   *
> - * TODO: multiqueue support is currently not implemented, even though
> - * macvtap is basically prepared for that. We will need to add this
> - * here as well as in virtio-net and qemu to get line rate on 10gbit
> - * adapters from a guest.
>   */
>  struct macvtap_queue {
>  	struct sock sk;
> @@ -1027,7 +1023,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  		return macvtap_ioctl_set_queue(file, u);
>  
>  	case TUNGETFEATURES:
> -		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR, up))
> +		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR |
> +			     IFF_MULTI_QUEUE, up))
>  			return -EFAULT;
>  		return 0;
>  
> -- 
> 1.7.1
