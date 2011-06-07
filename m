From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [PATCH] e100: Fix inconsistency in bad frames handling
Date: Tue, 07 Jun 2011 07:11:30 +0200
Message-ID: <1307423490.2642.61.camel@edumazet-laptop>
References: <20110606214454.4108aff4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Andrea Merello <andrea.merello@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64165 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323Ab1FGFLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 01:11:35 -0400
Received: by wya21 with SMTP id 21so3277935wya.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 22:11:34 -0700 (PDT)
In-Reply-To: <20110606214454.4108aff4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 21:44 -0700, Andrew Morton a =C3=A9crit :
>=20
> Begin forwarded message:
>=20
> Date: Sun, 5 Jun 2011 03:14:49 +0200
> From: Andrea Merello <andrea.merello@gmail.com>
> To: linux-kernel@vger.kernel.org
> Subject: [PATCH] e100: Fix inconsistency in bad frames handling
>=20
>=20
> Hello!
>=20
> In e100 driver it seems that the intention was to accept bad frames i=
n
> promiscuous mode and loopback mode.
> I think this is evident because of the following code in the driver:
>=20
> if (nic->flags & promiscuous || nic->loopback) {
>                config->rx_save_bad_frames =3D 0x1;       /* 1=3Dsave,=
 0=3Ddiscard */
>                config->rx_discard_short_frames =3D 0x0;  /* 1=3Ddisca=
rd, 0=3Dsave */
>                config->promiscuous_mode =3D 0x1;         /* 1=3Don, 0=
=3Doff */
>        }
>=20
>=20
> However this intention is not really realized because bad frames are
> discarded later by SW check.
> This patch finally honors the above intention, making the RX code to
> let bad frames to pass when the NIC is in promiscuous or loopback
> mode.
>=20
> This helped me a lot to debug an FPGA ethernet core.
> Maybe it can be also useful to someone else..
>=20
> Thanks
> Andrea
>=20
>  --- drivers/net/e100_orig.c     2011-06-14 23:29:38.322267075 +0200
> +++ drivers/net/e100.c  2011-06-14 23:34:10.700791472 +0200
> @@ -1975,7 +1975,8 @@ static int e100_rx_indicate(struct nic *
>        skb_put(skb, actual_size);
>        skb->protocol =3D eth_type_trans(skb, nic->netdev);
>=20
> -       if (unlikely(!(rfd_status & cb_ok))) {
> +       if (unlikely(!(nic->flags & promiscuous || nic->loopback) &&
> +           !(rfd_status & cb_ok))) {
>                /* Don't indicate if hardware indicates errors */
>                dev_kfree_skb_any(skb);
>        } else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {


Thanks Andrew, subject already opened on netdev :)

http://www.spinics.net/lists/netdev/msg166301.html

Lets close this thread and continue on previous one ?



