From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] e1000: allow option to limit number of
 descriptors down to 48 per ring
Date: Tue, 20 Jul 2010 06:40:23 +0200
Message-ID: <1279600823.2458.59.camel@edumazet-laptop>
References: <20100719234219.13875.90302.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62048 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab0GTEke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 00:40:34 -0400
Received: by wwj40 with SMTP id 40so294350wwj.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 21:40:30 -0700 (PDT)
In-Reply-To: <20100719234219.13875.90302.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 juillet 2010 =C3=A0 16:43 -0700, Jeff Kirsher a =C3=A9crit =
:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>=20
> This change makes it possible to limit the number of descriptors down=
 to 48
> per ring.  The reason for this change is to address a variation on ha=
rdware
> errata 10 for 82546GB in which descriptors will be lost if more than =
32
> descriptors are fetched and the PCI-X MRBC is 512.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>=20
>  drivers/net/e1000/e1000.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
> index 40b62b4..65298a6 100644
> --- a/drivers/net/e1000/e1000.h
> +++ b/drivers/net/e1000/e1000.h
> @@ -86,12 +86,12 @@ struct e1000_adapter;
>  /* TX/RX descriptor defines */
>  #define E1000_DEFAULT_TXD                  256
>  #define E1000_MAX_TXD                      256
> -#define E1000_MIN_TXD                       80
> +#define E1000_MIN_TXD                       48
>  #define E1000_MAX_82544_TXD               4096
> =20
>  #define E1000_DEFAULT_RXD                  256
>  #define E1000_MAX_RXD                      256
> -#define E1000_MIN_RXD                       80
> +#define E1000_MIN_RXD                       48
>  #define E1000_MAX_82544_RXD               4096
> =20
>  #define E1000_MIN_ITR_USECS		10 /* 100000 irq/sec */
>=20

So this limit is a pure software one ?

Why not let an admin chose a lower limit if he wants to ?

I am asking because big ring sizes can be a latency source in some
workloads.

Thanks


