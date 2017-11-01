From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC 01/12] net: bpf: rename ndo_xdp to ndo_bpf
Date: Wed, 1 Nov 2017 08:41:42 +0100
Message-ID: <20171101084142.5a5a9afc@redhat.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
        <20171101015217.10666-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60164 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751367AbdKAHlt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 03:41:49 -0400
In-Reply-To: <20171101015217.10666-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 18:52:06 -0700
Jakub Kicinski <jakub.kicinski@netronome.com> wrote:

> ndo_xdp is a control path callback for setting up XDP in the
> driver.  We can reuse it for other forms of communication
> between the eBPF stack and the drivers.  Rename the callback
> and associated structures and definitions.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  2 +-
>  drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      |  2 +-
>  drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h      |  2 +-
>  drivers/net/ethernet/cavium/thunder/nicvf_main.c   |  4 +--
>  drivers/net/ethernet/intel/i40e/i40e_main.c        |  6 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  4 +--
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  6 ++--
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  4 +--
>  .../net/ethernet/netronome/nfp/nfp_net_common.c    |  4 +--
>  drivers/net/ethernet/qlogic/qede/qede.h            |  2 +-
>  drivers/net/ethernet/qlogic/qede/qede_filter.c     |  2 +-
>  drivers/net/ethernet/qlogic/qede/qede_main.c       |  4 +--
>  drivers/net/tun.c                                  |  4 +--
>  drivers/net/virtio_net.c                           |  4 +--
>  include/linux/netdevice.h                          | 23 ++++++++-------
>  net/core/dev.c                                     | 34 +++++++++++-----------
>  net/core/rtnetlink.c                               |  4 +--
>  17 files changed, 56 insertions(+), 55 deletions(-)
> 
[...]
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 507977994a03..e5dcb25be398 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -10004,7 +10004,7 @@ static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
>  	return 0;
>  }
>  
> -static int ixgbe_xdp(struct net_device *dev, struct netdev_xdp *xdp)
> +static int ixgbe_xdp(struct net_device *dev, struct netdev_bpf *xdp)
>  {
>  	struct ixgbe_adapter *adapter = netdev_priv(dev);
>  
> @@ -10113,7 +10113,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
>  	.ndo_udp_tunnel_add	= ixgbe_add_udp_tunnel_port,
>  	.ndo_udp_tunnel_del	= ixgbe_del_udp_tunnel_port,
>  	.ndo_features_check	= ixgbe_features_check,
> -	.ndo_xdp		= ixgbe_xdp,
> +	.ndo_bpf		= ixgbe_xdp,
>  	.ndo_xdp_xmit		= ixgbe_xdp_xmit,
>  	.ndo_xdp_flush		= ixgbe_xdp_flush,
>  };
[...]
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index fc059f193e7d..edf984406ba0 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -2115,7 +2115,7 @@ static const struct net_device_ops virtnet_netdev = {
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller = virtnet_netpoll,
>  #endif
> -	.ndo_xdp		= virtnet_xdp,
> +	.ndo_bpf		= virtnet_xdp,
>  	.ndo_xdp_xmit		= virtnet_xdp_xmit,
>  	.ndo_xdp_flush		= virtnet_xdp_flush,
>  	.ndo_features_check	= passthru_features_check,

Sorry, but I don't understand why this rename is needed.

Are you going to add another type than BPF_PROG_TYPE_XDP?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
