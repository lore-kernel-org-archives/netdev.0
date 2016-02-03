From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] hv_netvsc: Add feature flags NETIF_F_IPV6_CSUM
 and NETIF_F_TSO6 for netvsc
Date: Wed, 3 Feb 2016 12:02:04 -0800
Message-ID: <CALx6S37M5Q9j1YUUMwbAWYim13NN4qvcG402yQT3yJfdUOyA6Q@mail.gmail.com>
References: <1454535041-14893-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	devel@linuxdriverproject.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Simon Xiao <sixiao@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454535041-14893-1-git-send-email-sixiao@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 3, 2016 at 1:30 PM, Simon Xiao <sixiao@microsoft.com> wrote:
> 1. Adding NETIF_F_IPV6_CSUM and NETIF_F_TSO6 feature flags which are
> supported by Hyper-V platform.

NETIF_F_IPV6_CSUM and NETIF_F_IP_CSUM are being deprecated. Please
change to use NETIF_F_HW_CSUM (calling helper functions if need).

Thanks,
Tom

> 2. Cleanup the coding style of flag assignment by using macro.
>
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 1d3a665..0cde741 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -43,6 +43,12 @@
>
>  #define RING_SIZE_MIN 64
>  #define LINKCHANGE_INT (2 * HZ)
> +#define NETVSC_HW_FEATURES     (NETIF_F_RXCSUM | \
> +                                NETIF_F_SG | \
> +                                NETIF_F_TSO | \
> +                                NETIF_F_TSO6 | \
> +                                NETIF_F_IP_CSUM | \
> +                                NETIF_F_IPV6_CSUM)
>  static int ring_size = 128;
>  module_param(ring_size, int, S_IRUGO);
>  MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
> @@ -1081,10 +1087,8 @@ static int netvsc_probe(struct hv_device *dev,
>
>         net->netdev_ops = &device_ops;
>
> -       net->hw_features = NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM |
> -                               NETIF_F_TSO;
> -       net->features = NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM |
> -                       NETIF_F_IP_CSUM | NETIF_F_TSO;
> +       net->hw_features = NETVSC_HW_FEATURES;
> +       net->features = NETVSC_HW_FEATURES | NETIF_F_HW_VLAN_CTAG_TX;
>
>         net->ethtool_ops = &ethtool_ops;
>         SET_NETDEV_DEV(net, &dev->device);
> --
> 2.5.0
>
