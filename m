From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 14:29:51 +0100
Message-ID: <1298035791.6201.56.camel@edumazet-laptop>
References: <20110218132524.GC2939@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44156 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab1BRNaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 08:30:05 -0500
Received: by fxm20 with SMTP id 20so3768200fxm.19
        for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 05:30:03 -0800 (PST)
In-Reply-To: <20110218132524.GC2939@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 14:25 +0100, Jiri Pirko a =C3=A9=
crit :
> This patch converts bonding to use rx_handler. Results in cleaner
> __netif_receive_skb() with much less exceptions needed. Also bond-spe=
cific
> work is moved into bond code.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c |   75 ++++++++++++++++++++-
>  include/linux/skbuff.h          |    2 +
>  net/core/dev.c                  |  144 +++++++++++------------------=
---------
>  net/core/skbuff.c               |    1 +
>  4 files changed, 119 insertions(+), 103 deletions(-)
>=20

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 31f02d0..9f3af5d 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -267,6 +267,7 @@ typedef unsigned char *sk_buff_data_t;
>   *	@sk: Socket we are owned by
>   *	@tstamp: Time we arrived
>   *	@dev: Device we arrived on/are leaving by
> + *	@input_dev: Original device on which we arrived
>   *	@transport_header: Transport layer header
>   *	@network_header: Network layer header
>   *	@mac_header: Link layer header
> @@ -325,6 +326,7 @@ struct sk_buff {
> =20
>  	struct sock		*sk;
>  	struct net_device	*dev;
> +	struct net_device	*input_dev;
> =20

Your patch looks fine, but adding 8 bytes to sk_buff for a "cleanup" is
really a show stopper for me.



