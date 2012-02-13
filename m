From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ixgbe: fix truesize calculation when merging active
 tail into lro skb
Date: Mon, 13 Feb 2012 15:12:02 +0100
Message-ID: <1329142322.2494.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120213135248.GA23457@sir.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Christian Brunner <chb@muc.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61561 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946Ab2BMOMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 09:12:05 -0500
Received: by werb13 with SMTP id b13so3494198wer.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 06:12:04 -0800 (PST)
In-Reply-To: <20120213135248.GA23457@sir.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 f=C3=A9vrier 2012 =C3=A0 14:52 +0100, Christian Brunner a =C3=
=A9crit :
> I'm seeing some page allocation failures with the ixgbe driver under =
heavy
> load. While looking after it, I came accoss the truesize handling. I =
suspect,
> that there is a small misstake in ixgbe_merge_active_tail(). (But I'm=
 not
> really sure).
>=20
> Truesize allocation of the skb may be larger than skb->len, because
> ixgbe is allocating PAGE_SIZE/2 for received fragments. Hence we=20
> should use the truesize of the tail when merging.
>=20
> Signed-off-by: Christian Brunner <chb@muc.de>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/=
net/ethernet/intel/ixgbe/ixgbe_main.c
> index a42b0b2..c4d25af 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1222,7 +1222,7 @@ static inline struct sk_buff *ixgbe_merge_activ=
e_tail(struct sk_buff *tail)
> =20
>  	head->len +=3D tail->len;
>  	head->data_len +=3D tail->len;
> -	head->truesize +=3D tail->len;
> +	head->truesize +=3D tail->truesize;
> =20
>  	IXGBE_CB(tail)->head =3D NULL;
> =20

You forgot CC Intel guys, but they usually catch netdev traffic :)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
