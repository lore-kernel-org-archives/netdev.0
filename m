From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH] net: Add batman-adv meshing protocol
Date: Tue, 20 Jul 2010 10:28:10 +0200
Message-ID: <201007201028.12470.sven.eckelmann@gmx.de>
References: <1279291156-5297-1-git-send-email-sven.eckelmann@gmx.de>
	<1279291156-5297-2-git-send-email-sven.eckelmann@gmx.de>
	<20100719.212625.255369607.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5811515.oMvAPjbWXS";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20100719.212625.255369607.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart5811515.oMvAPjbWXS
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Thanks a lot for your review and for your hints.

David Miller wrote:
> From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
> Date: Fri, 16 Jul 2010 16:39:16 +0200
[...]
>=20
> The kernel has a hamming weight library function which takes advantage
> of population count instructions on cpus that suport it, and also has
> a sw version than is faster than what you're doing here, please use
> it.
>=20
> The interfaces are called "hweight{8,16,32,64}()" where the number in
> the name indicates the bit-size of the word the interface operates on.

Correct, the inner loop is a quite straight forward implementation without =
any=20
kind of optimization. I will change that.

> I also notice that this code uses it's own internal buffering scheme
> with kmalloc()'d buffers, then seperately allocates actual SKB's and
> copies the data there.
>=20
> Just use the SKB facilities how they were designed to be used, instead
> of needlessly inventing new things.  Allocate your initial SKB and put
> the initial forwarding header in it, then when you want to send a copy
> off, skb_clone() it, and push the other bits you want at the head
> and/or the tail of the cloned SKB, then simply send it off.

Good catch. That comes from a time when batman-adv was a minimalistic=20
conversation of the userspace proof of concept implementation. This happens=
=20
for example in vis.c, icmp_socket.c and send.c (just grepping for=20
send_raw_packet is a good way to find those places). But is also happening=
=20
with batman_if->packet_buff in schedule_own_packet and similar places.

I would leave that to the original author of those functions.

thanks,
	Sven

--nextPart5811515.oMvAPjbWXS
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJMRV4bAAoJEF2HCgfBJntGScEQAMNQ+GiKsSZ78hHhaYGkkqqq
xpif8B24NbB0s5hAquZcFQPJKHh+QDs54c0bQQxGmrNx4ycVo/vxEVIVbHdz13Ma
b1tldA7FwbgLCgWlABC2Ozyj+6cmjpcis1MnL32uv1Tpg+bzOoXaooByxE6g6OnR
z0Z6uJLw7OUX8z6rOy5rtBTK812fEJl3VjxJEg+BY/MZb4ljyGAONhigJvWyRcor
7mXn5gsLQiRckWb4Be1bc5wFGgTdkUMAlOK1r95+rucUWMkPhfwqUo0wWXPr3SFh
eRP61pjQDg3huTteokuPcc5kc9YZMFUKac3sJec6SjEoGJO56CbugW21rh/u6Vs1
lbZjAvztMNa2WLW1Y8CvhdTzczMaDxz5C28djbrWSvDiY9EQxInFiXgoXv0k+VAx
1bidgOfiCcE/0kH5LD+vgwagRn3vPNFo6660wiqTsTe9kWuhCYz5de67fdfC9sGK
OwZziEr2LNWchxdzCVwcsIjbVbVR6dhDupRHQMT2pZDlR6Td2wzMiB4w7uBpZF6d
PLC5eT+U9NcVgrJ9r9A3qfCZwrK605weE/fyZYDTY2u34gUxyYnetJq2roObVSwE
IpTX7eMN7m78cwY/khgj9EzJm/SNQPoQuQHehqNDXZqMo3rvuUX7gY6t6DJ83Q0n
gS6UQPYTMh6bzJ/acXMq
=GhdV
-----END PGP SIGNATURE-----

--nextPart5811515.oMvAPjbWXS--
