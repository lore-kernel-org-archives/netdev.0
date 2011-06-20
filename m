From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] myri10ge: 64bit slice stats
Date: Mon, 20 Jun 2011 20:49:18 +0200
Message-ID: <1308595758.2658.16.camel@edumazet-laptop>
References: <20110620184635.GA18577@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>
To: Jon Mason <jon.mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40371 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab1FTStV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 14:49:21 -0400
Received: by wwe5 with SMTP id 5so2856103wwe.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 11:49:20 -0700 (PDT)
In-Reply-To: <20110620184635.GA18577@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 13:46 -0500, Jon Mason a =C3=A9crit :
> There is a potential issue of internal 32bit stats wrapping before
> updating the external 64bit stats, thus leading to incorrect stats.
> Since there is no hardware necessity for these counters to be 32bit,
> change them to be 64bit to avoid this issue.
>=20
> Patch suggested by Eric Dumazet.
>=20
> Signed-off-by: Jon Mason <mason@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/m=
yri10ge.c
> index 04e10f4..2a51de1 100644
> --- a/drivers/net/myri10ge/myri10ge.c
> +++ b/drivers/net/myri10ge/myri10ge.c
> @@ -170,12 +170,12 @@ struct myri10ge_rx_done {
>  };
> =20
>  struct myri10ge_slice_netstats {
> -	unsigned long rx_packets;
> -	unsigned long tx_packets;
> -	unsigned long rx_bytes;
> -	unsigned long tx_bytes;
> -	unsigned long rx_dropped;
> -	unsigned long tx_dropped;
> +	u64 rx_packets;
> +	u64 tx_packets;
> +	u64 rx_bytes;
> +	u64 tx_bytes;
> +	u64 rx_dropped;
> +	u64 tx_dropped;
>  };
> =20
>  struct myri10ge_slice_state {

Hmm, no sorry, this wont work on 32bit arches :(

Please take a look at various patches addressing this problem.



