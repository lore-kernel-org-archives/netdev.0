From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v5 net-next 02/14] net: define gso types for IPx over IPv4
 and IPv6
Date: Mon, 16 May 2016 09:32:58 -0700
Message-ID: <CAKgT0Uc1mQwP4xoQxM9J08kyEaxKpZse5nWdctgrrmjJowebJg@mail.gmail.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
	<1463355755-3481375-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34832 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007AbcEPQdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 12:33:12 -0400
Received: by mail-io0-f182.google.com with SMTP id d62so216409630iof.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 09:32:58 -0700 (PDT)
In-Reply-To: <1463355755-3481375-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 15, 2016 at 4:42 PM, Tom Herbert <tom@herbertland.com> wrote:
> This patch defines two new GSO definitions SKB_GSO_IPXIP4 and
> SKB_GSO_IPXIP6 along with corresponding NETIF_F_GSO_IPXIP4 and
> NETIF_F_GSO_IPXIP6. These are used to described IP in IP
> tunnel and what the outer protocol is. The inner protocol
> can be deduced from other GSO types (e.g. SKB_GSO_TCPV4 and
> SKB_GSO_TCPV6). The GSO types of SKB_GSO_IPIP and SKB_GSO_SIT
> are removed (these are both instances of SKB_GSO_IPXIP4).
> SKB_GSO_IPXIP6 will be used when support for GSO with IP
> encapsulation over IPv6 is added.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  5 ++---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  4 ++--
>  drivers/net/ethernet/intel/i40e/i40e_main.c       |  3 +--
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  3 +--
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  3 +--
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  3 +--
>  drivers/net/ethernet/intel/igb/igb_main.c         |  3 +--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  3 +--
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +--
>  include/linux/netdev_features.h                   | 12 ++++++------
>  include/linux/netdevice.h                         |  4 ++--
>  include/linux/skbuff.h                            |  4 ++--
>  net/core/ethtool.c                                |  4 ++--
>  net/ipv4/af_inet.c                                |  2 +-
>  net/ipv4/ipip.c                                   |  2 +-
>  net/ipv6/ip6_offload.c                            |  4 ++--
>  net/ipv6/sit.c                                    |  4 ++--
>  net/netfilter/ipvs/ip_vs_xmit.c                   | 17 +++++++----------
>  18 files changed, 36 insertions(+), 47 deletions(-)

It looks like you missed drivers/net/ethernet/intel/igb/netdev.c.  If
you don't get it then it will break the build.

Thanks.

- Alex
