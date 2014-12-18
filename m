From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 00/10] Split UFO into v4 and v6 versions.
Date: Thu, 18 Dec 2014 00:28:52 -0500 (EST)
Message-ID: <586203981.237162.1418880532523.JavaMail.zimbra@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, ben@decadent.org.uk,
	stefanha@redhat.com, virtualization@lists.linux-foundation.org
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:50835 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbaLRF3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 00:29:07 -0500
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> UFO support in the kernel applies to both IPv4 and IPv6 protocols
> with the same device feature.  However some devices may not be able
> to support one of the offloads.  For this we split the UFO offload
> feature into 2 pieces.  NETIF_F_UFO now controlls the IPv4 part and
> this series introduces NETIF_F_UFO6.
> 
> As a result of this work, we can now re-enable NETIF_F_UFO on
> virtio_net devices and restore UDP over IPv4 performance for guests.
> We also continue to support legacy guests that assume that UFO6
> support included into UFO(4).
> 
> Without this work, migrating a guest to a 3.18 kernel fails.
> 

This series eliminate the ambiguous NETIF_F_UFO.

But VIRTIO_NET_F_{HOST|GUEST}_UFO and VIRTIO_NET_F_HDR_GSO_UDP is still
ambigious. I know it was used to keep compatibility for legacy guest. But
what's the future plan? Differentiate UFOv4 and UFOv6 in virtio features and
gso type in vnet header looks sufficient?

With the series, we can't send UFOv6 packet but legacy guest can. How about
fix the UFOv6 also in this series?

Thanks
> Vladislav Yasevich (10):
>   core: Split out UFO6 support
>   net:  Correctly mark IPv6 UFO offload type.
>   ovs: Enable handling of UFO6 packets.
>   loopback: Turn on UFO6 support.
>   veth: Enable UFO6 support.
>   macvlan: Enable UFO6 support.
>   s2io: Enable UFO6 support.
>   tun: Re-uanble UFO support.
>   macvtap: Re-enable UFO support
>   Revert "drivers/net: Disable UFO through virtio"
> 
>  drivers/net/ethernet/neterion/s2io.c |  6 +++---
>  drivers/net/loopback.c               |  4 ++--
>  drivers/net/macvlan.c                |  2 +-
>  drivers/net/macvtap.c                | 20 ++++++++++++++------
>  drivers/net/tun.c                    | 26 ++++++++++++++------------
>  drivers/net/veth.c                   |  2 +-
>  drivers/net/virtio_net.c             | 24 ++++++++++--------------
>  include/linux/netdev_features.h      |  7 +++++--
>  include/linux/netdevice.h            |  1 +
>  include/linux/skbuff.h               |  1 +
>  net/core/dev.c                       | 35
>  +++++++++++++++++++----------------
>  net/core/ethtool.c                   |  2 +-
>  net/ipv6/ip6_offload.c               |  1 +
>  net/ipv6/ip6_output.c                |  4 ++--
>  net/ipv6/udp_offload.c               |  3 ++-
>  net/mpls/mpls_gso.c                  |  1 +
>  net/openvswitch/datapath.c           |  3 ++-
>  net/openvswitch/flow.c               |  2 +-
>  18 files changed, 81 insertions(+), 63 deletions(-)
> 
> --
> 1.9.3
> 
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
> 
