From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/9] ifb: convert to 64 bit stats
Date: Thu, 09 Jun 2011 05:29:06 +0200
Message-ID: <1307590146.3980.28.camel@edumazet-laptop>
References: <20110609005356.160260858@vyatta.com>
	 <20110609005417.507470402@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60785 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531Ab1FID3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 23:29:10 -0400
Received: by wya21 with SMTP id 21so813282wya.19
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 20:29:09 -0700 (PDT)
In-Reply-To: <20110609005417.507470402@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 juin 2011 =C3=A0 17:54 -0700, Stephen Hemminger a =C3=A9=
crit :
> pi=C3=A8ce jointe document texte brut (ifb-stats64.patch)
> Convert input functional block device to use 64 bit stats.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> --- a/drivers/net/ifb.c	2011-06-07 16:58:31.317079332 -0700
> +++ b/drivers/net/ifb.c	2011-06-07 17:29:02.958161955 -0700
> @@ -42,7 +42,14 @@ struct ifb_private {
>  	struct tasklet_struct   ifb_tasklet;
>  	int     tasklet_pending;
>  	struct sk_buff_head     rq;
> +	u64 rx_packets;
> +	u64 rx_bytes;
> +	u64 rx_dropped;
> +
>  	struct sk_buff_head     tq;
> +	u64 tx_packets;
> +	u64 tx_bytes;
> +	u64 tx_dropped;
>  };
> =20

Hi Stephen

This needs special synchronization on 32bit arches, as Ben pointed out
for other drivers.



