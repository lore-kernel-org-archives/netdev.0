From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: add IFF_SKB_TX_SHARED flag to priv_flags
Date: Mon, 25 Jul 2011 22:11:22 +0200
Message-ID: <1311624682.2996.1.camel@edumazet-laptop>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	 <1311623120-26839-1-git-send-email-nhorman@tuxdriver.com>
	 <1311623120-26839-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Robert Olsson <robert.olsson@its.uu.se>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55531 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360Ab1GYUL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 16:11:27 -0400
Received: by wyg8 with SMTP id 8so2998629wyg.19
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2011 13:11:26 -0700 (PDT)
In-Reply-To: <1311623120-26839-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 juillet 2011 =C3=A0 15:45 -0400, Neil Horman a =C3=A9crit :
> Pktgen attempts to transmit shared skbs to net devices, which can't b=
e used by
> some drivers as they keep state information in skbs.  This patch adds=
 a flag
> marking drivers as being able to handle shared skbs in their tx path.=
  Drivers
> are defaulted to being unable to do so, but calling ether_setup enabl=
es this
> flag, as 90% of the drivers calling ether_setup touch real hardware a=
nd can
> handle shared skbs.  A subsequent patch will audit drivers to ensure =
that the
> flag is set properly
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Jiri Pirko <jpirko@redhat.com>
> CC: Robert Olsson <robert.olsson@its.uu.se>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Alexey Dobriyan <adobriyan@gmail.com>
> CC: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/if.h |    2 ++
>  net/core/pktgen.c  |    8 +++++---
>  net/ethernet/eth.c |    1 +
>  3 files changed, 8 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/if.h b/include/linux/if.h
> index 3bc63e6..03489ca 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -76,6 +76,8 @@
>  #define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
>  #define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
>  					 * datapath port */
> +#define IFF_TX_SKB_SHARING	0x10000	/* The interface supports sharing
> +					 * skbs on transmit */
> =20
>  #define IF_GET_IFACE	0x0001		/* for querying only */
>  #define IF_GET_PROTO	0x0002
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index f76079c..53f3f15 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -1070,7 +1070,9 @@ static ssize_t pktgen_if_write(struct file *fil=
e,
>  		len =3D num_arg(&user_buffer[i], 10, &value);
>  		if (len < 0)
>  			return len;
> -
> +		if ((len > 0) &&

		if ((value > 0) ...

> +		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
> +			return -ENOTSUPP;
>  		i +=3D len;
>  		pkt_dev->clone_skb =3D value;
> =20



