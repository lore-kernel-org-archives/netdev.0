From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v5 net-next 02/14] net: define gso types for IPx over IPv4
 and IPv6
Date: Mon, 16 May 2016 09:52:13 -0700
Message-ID: <CAKgT0Uc4DdjyoVRa9Lu0__35G-bqN_Jw0WQGF6jRtDqDar-e5w@mail.gmail.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
	<1463355755-3481375-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36227 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305AbcEPQwO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 12:52:14 -0400
Received: by mail-io0-f194.google.com with SMTP id k129so27235199iof.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 09:52:14 -0700 (PDT)
In-Reply-To: <1463355755-3481375-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 15, 2016 at 4:42 PM, Tom Herbert <tom@herbertland.com> wrot=
e:
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
>  net/netfilter/ipvs/ip_vs_xmit.c                   | 17 +++++++------=
----
>  18 files changed, 36 insertions(+), 47 deletions(-)
>

<...>

> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/=
ethernet/broadcom/bnxt/bnxt.c
> index 5a0dca3..bfc1e94 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -6311,7 +6311,7 @@ static int bnxt_init_one(struct pci_dev *pdev, =
const struct pci_device_id *ent)
>         dev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NE=
TIF_F_SG |
>                            NETIF_F_TSO | NETIF_F_TSO6 |
>                            NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
> -                          NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
> +                          NETIF_F_GSO_IPXIP4 |
>                            NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_=
GRE_CSUM |
>                            NETIF_F_GSO_PARTIAL | NETIF_F_RXHASH |
>                            NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO=
;
> @@ -6321,7 +6321,7 @@ static int bnxt_init_one(struct pci_dev *pdev, =
const struct pci_device_id *ent)
>                         NETIF_F_TSO | NETIF_F_TSO6 |
>                         NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
>                         NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE=
_CSUM |
> -                       NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
> +                       NETIF_F_GSO_IPXIP4;
>                         NETIF_F_GSO_PARTIAL;
>         dev->gso_partial_features =3D NETIF_F_GSO_UDP_TUNNEL_CSUM |
>                                     NETIF_F_GSO_GRE_CSUM;

This bit here is breaking the build as well.  It should be a '|'
following the IPXIP4, not a ';'.  As it currently is it is generating
the following error:

drivers/net/ethernet/broadcom/bnxt/bnxt.c: In function =E2=80=98bnxt_in=
it_one=E2=80=99:
include/linux/netdev_features.h:88:28: warning: statement with no
effect [-Wunused-value]
 #define __NETIF_F_BIT(bit) ((netdev_features_t)1 << (bit))
                            ^
include/linux/netdev_features.h:89:26: note: in expansion of macro
=E2=80=98__NETIF_F_BIT=E2=80=99
 #define __NETIF_F(name)  __NETIF_F_BIT(NETIF_F_##name##_BIT)
                          ^
include/linux/netdev_features.h:129:30: note: in expansion of macro =E2=
=80=98__NETIF_F=E2=80=99
 #define NETIF_F_GSO_PARTIAL  __NETIF_F(GSO_PARTIAL)
                              ^
drivers/net/ethernet/broadcom/bnxt/bnxt.c:6325:4: note: in expansion
of macro =E2=80=98NETIF_F_GSO_PARTIAL=E2=80=99
    NETIF_F_GSO_PARTIAL;
    ^

- Alex
