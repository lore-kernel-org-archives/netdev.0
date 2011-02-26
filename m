From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: Re: [RFC] be2net: add rxhash support
Date: Sat, 26 Feb 2011 15:11:35 -0600
Message-ID: <20110226211135.GA12549@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:32180 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751151Ab1BZVL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 16:11:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Saturday, February 26, 2011 4:31 AM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC] be2net: add rxhash support
>=20
> Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 15:35 -0600, Ajit Khaparde a =
=C3=A9crit :
>=20
> > I asked that because, if a switch is part a of the configuration,
> > the ASIC can receive packets other than the tcp flow.
> >
> > And if hashing is enabled for IP packets, we can see this behavior.
> > The other values indicate that hashing has been enabled for IPv4
> packets.
>=20
> To make sure RSS (and rxhash) was OK, I added following debugging aid=
 :
>=20
> diff --git a/include/net/sock.h b/include/net/sock.h
> index da0534d..e9b1180 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -688,6 +688,7 @@ static inline void sock_rps_save_rxhash(struct so=
ck
> *sk, u32 rxhash)
>  {
>  #ifdef CONFIG_RPS
>  	if (unlikely(sk->sk_rxhash !=3D rxhash)) {
> +		pr_err("rxhash change from %x to %x\n", sk->sk_rxhash,
> rxhash);
>  		sock_rps_reset_flow(sk);
>  		sk->sk_rxhash =3D rxhash;
>  	}
>=20
>=20
> And got following traces :
>=20
> [  201.170297] change rxhash from 0 to be0b5a87
> [  232.607474] bonding: bond1: Setting eth3 as active slave.
> [  232.607478] bonding: bond1: making interface eth3 the new active
> one.
> [  232.710848] change rxhash from be0b5a87 to e56a3c1e
> [  300.047500] bonding: bond1: Setting eth1 as active slave.
> [  300.047504] bonding: bond1: making interface eth1 the new active
> one.
> [  300.159162] change rxhash from e56a3c1e to be0b5a87
>=20
> The flip occured when I changed my active slave (bonding mode=3D1).
>=20
> eth1 is a bnx2 NIC, while eth3 a be2net one, so its OK to change the
> rxhash in this case
> (different firmware/algo)
>=20
> So as far as be2net is concerned, everything seems OK : all packets f=
or
> a given flow get an unique RSS hash and can feed skb->rxhash
>=20
=46air enough. Thanks.
I guess a fresh patch with the ethtool support included will be ideal,
instead of the previous patch?

-Ajit
