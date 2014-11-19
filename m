From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] tun: move internal flag defines out of uapi
Date: Wed, 19 Nov 2014 10:47:14 -0600
Message-ID: <1416415634.4763.9.camel@dcbw.local>
References: <1416413891-29562-1-git-send-email-mst@redhat.com>
	 <1416413891-29562-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Zhi Yong Wu <wuzhy-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Masatake YAMATO <yamato-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Xi Wang <xii-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416413891-29562-2-git-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-11-19 at 18:18 +0200, Michael S. Tsirkin wrote:
> TUN_ flags are internal and never exposed
> to userspace. Any application using it is almost
> certainly buggy.

Except for TUN_TUN_DEV and TUN_TAP_DEV and TUN_TYPE_MASK...  which we're
using (for some reason) in NetworkManager, though I'll happily convert
those to IFF_* instead.  It might be worth #defining those to their
IFF_* equivalents since their usage is not technically broken.

Dan

> Move them out to tun.c, we'll remove them in follow-up patches.
> Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  include/uapi/linux/if_tun.h | 14 --------------
>  drivers/net/tun.c           | 14 ++++++++++++++
>  2 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
> index e9502dd..b82c276 100644
> --- a/include/uapi/linux/if_tun.h
> +++ b/include/uapi/linux/if_tun.h
> @@ -23,20 +23,6 @@
>  /* Read queue size */
>  #define TUN_READQ_SIZE	500
>  
> -/* TUN device flags */
> -#define TUN_TUN_DEV 	0x0001	
> -#define TUN_TAP_DEV	0x0002
> -#define TUN_TYPE_MASK   0x000f
> -
> -#define TUN_FASYNC	0x0010
> -#define TUN_NOCHECKSUM	0x0020
> -#define TUN_NO_PI	0x0040
> -/* This flag has no real effect */
> -#define TUN_ONE_QUEUE	0x0080
> -#define TUN_PERSIST 	0x0100	
> -#define TUN_VNET_HDR 	0x0200
> -#define TUN_TAP_MQ      0x0400
> -
>  /* Ioctl defines */
>  #define TUNSETNOCSUM  _IOW('T', 200, int) 
>  #define TUNSETDEBUG   _IOW('T', 201, int) 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 2e18ddd..81735f5 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -103,6 +103,20 @@ do {								\
>  } while (0)
>  #endif
>  
> +/* TUN device flags */
> +#define TUN_TUN_DEV 	0x0001
> +#define TUN_TAP_DEV	0x0002
> +#define TUN_TYPE_MASK   0x000f
> +
> +#define TUN_FASYNC	0x0010
> +#define TUN_NOCHECKSUM	0x0020
> +#define TUN_NO_PI	0x0040
> +/* This flag has no real effect */
> +#define TUN_ONE_QUEUE	0x0080
> +#define TUN_PERSIST 	0x0100
> +#define TUN_VNET_HDR 	0x0200
> +#define TUN_TAP_MQ      0x0400
> +
>  #define GOODCOPY_LEN 128
>  
>  #define FLT_EXACT_COUNT 8
