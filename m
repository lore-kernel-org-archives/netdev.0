From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-2.6 PATCH] ixgbe: cleanup maximum number of tx queues
Date: Wed, 24 Mar 2010 21:08:54 +0100
Message-ID: <1269461334.2849.3.camel@edumazet-laptop>
References: <20100324200144.6384.17291.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:33922 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab0CXUJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:09:00 -0400
Received: by bwz1 with SMTP id 1so277619bwz.21
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 13:08:58 -0700 (PDT)
In-Reply-To: <20100324200144.6384.17291.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 mars 2010 =C3=A0 13:01 -0700, Jeff Kirsher a =C3=A9crit =
:
> From: John Fastabend <john.r.fastabend@intel.com>
>=20
> In the last patch I missed an unecessary min_t comparison.
> This patch removes it, the path allocates at most
> 72 tx queues for 82599 and 24 for 82598 there is no need
> for this check.
>=20
> Additionally this sets MAX_[TX|RX]_QUEUES to 72.  Which is
> used as the size for the tx/rx_ring arrays. There is no
> reason to have more tx_rings/rx_rings then num_tx_queues.
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks guys
> ---
>=20
>  drivers/net/ixgbe/ixgbe.h      |    7 +++++--
>  drivers/net/ixgbe/ixgbe_main.c |    1 -
>  2 files changed, 5 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
> index 19e94ee..79c35ae 100644
> --- a/drivers/net/ixgbe/ixgbe.h
> +++ b/drivers/net/ixgbe/ixgbe.h
> @@ -204,14 +204,17 @@ enum ixgbe_ring_f_enum {
>  #define IXGBE_MAX_FDIR_INDICES 64
>  #ifdef IXGBE_FCOE
>  #define IXGBE_MAX_FCOE_INDICES  8
> +#define MAX_RX_QUEUES (IXGBE_MAX_FDIR_INDICES + IXGBE_MAX_FCOE_INDIC=
ES)
> +#define MAX_TX_QUEUES (IXGBE_MAX_FDIR_INDICES + IXGBE_MAX_FCOE_INDIC=
ES)
> +#else
> +#define MAX_RX_QUEUES IXGBE_MAX_FDIR_INDICES
> +#define MAX_TX_QUEUES IXGBE_MAX_FDIR_INDICES
>  #endif /* IXGBE_FCOE */
>  struct ixgbe_ring_feature {
>  	int indices;
>  	int mask;
>  } ____cacheline_internodealigned_in_smp;
> =20
> -#define MAX_RX_QUEUES 128
> -#define MAX_TX_QUEUES 128
> =20
>  #define MAX_RX_PACKET_BUFFERS ((adapter->flags & IXGBE_FLAG_DCB_ENAB=
LED) \
>                                ? 8 : 1)
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index 315622f..a9147e5 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -6041,7 +6041,6 @@ static int __devinit ixgbe_probe(struct pci_dev=
 *pdev,
>  	indices +=3D min_t(unsigned int, num_possible_cpus(),
>  			 IXGBE_MAX_FCOE_INDICES);
>  #endif
> -	indices =3D min_t(unsigned int, indices, MAX_TX_QUEUES);
>  	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter), indices)=
;
>  	if (!netdev) {
>  		err =3D -ENOMEM;
>=20
> --


