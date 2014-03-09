From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: TX timestamping for ICMP (sfc and core)?
Date: Sun, 09 Mar 2014 19:17:55 +0000
Message-ID: <1394392675.15968.21.camel@deadeye.wl.decadent.org.uk>
References: <CALCETrXpaD4i9V2Qv_0xfouGRb_y27-R6fOQ5v4Q97jNwgecFA@mail.gmail.com>
	 <1394384857.2861.159.camel@deadeye.wl.decadent.org.uk>
	 <CALCETrV_Zk6GWROQK8hEDwFzUDCtW_HX_xC5QhAFVXPzwgurXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fkP8o/dOpkH03xihlF3O"
Cc: Network Development <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51262 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750962AbaCITSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 15:18:04 -0400
In-Reply-To: <CALCETrV_Zk6GWROQK8hEDwFzUDCtW_HX_xC5QhAFVXPzwgurXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fkP8o/dOpkH03xihlF3O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-03-09 at 10:33 -0700, Andy Lutomirski wrote:
> On Sun, Mar 9, 2014 at 10:07 AM, Ben Hutchings <ben@decadent.org.uk> wrot=
e:
> > On Tue, 2014-03-04 at 12:43 -0800, Andy Lutomirski wrote:
> >> I'm trying to get tx timestamping working on ping sockets.  My program
> >> works fine (with hardware TX timestamps) if I send my "pings" on the
> >> PTP UDP ports.  I want to send real ICMP pings, though.
> >>
> >> It looks like there are two problems:
> >>
> >>  - Something in the core code seems to eat SKBTX_HW_STAMP on ping
> >> sockets.  At least, this code in efx_hard_start_xmit triggers for
> >> IPPROTO_UDP on PTP ports but not for IPPROTO_ICMP:
> >>
> >>         if (unlikely(efx_xmit_with_hwtstamp(skb)))
> >>                 printk(KERN_DEBUG "sfc: trying to do a TX timestamp\n"=
);
> >>
> >>  - The sfc driver refuses to timestamp non-PTP packets.  There's a
> >> check in efx_hard_start_xmit and another in ptp.c.  I suspect that the
> >> hardware can support timestamping any outgoing packet, but I'm not
> >> really sure.  (I'm using an SFN7322F.)
> >
> > I think that the SFC9100 family can do TX timestamping for arbitrary
> > packets, but they still have to be sent via the MC and that will greatl=
y
> > limit the packet rate.
> >
> > (It may or may not be possible on the SFN[56]322F, as the addition of
> > timestamping in a peripheral to the SFC9020 is quite a delicate
> > arrangement.  The MCDI transport there also limits TX timestamped
> > packets to 252 bytes.)
> >
> > If you want to send more than a very low rate of packets with TX
> > timestamping, the driver should probably tell the kernel to allocate an
> > extra TX queue for them and should implement ndo_select_queue.
>=20
> All of these packets should be flagged with SKBTX_HW_TSTAMP, so the
> driver will know that they need special treatment.  Is the issue that,
> if they end up on a queue with other packets, that they will block the
> other packets?

I think they might, because bql will count both packets in a hardware TX
queue and packets that were diverted to the software PTP queue.  I'm not
sure how much of a problem that could actually become.

> In any case, doing this on older hardware is probably useless, at
> least for me.  I want to implement fully hardware-timestamped ping (to
> be open-sourced once it works), and TX timestamps on echo requests
> aren't terribly useful without RX timestamps on echo replies / TTL
> exceeded messages, and the latter is impossible on older hardware, I
> think.

Right.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-fkP8o/dOpkH03xihlF3O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxy+Y+e/yOyVhhEJAQq7oA/9GVqFL7qbL4RcrF1FYQLZelOedEF/jwus
rarIl3jEu+r8E2EZSPlzgOawQa1JkPRAq3JaKHJY5r07ZDDQSdBML1rINFRu34EK
UL5YxS54ktwZUmbBSnUMgj97ltaebTtLfqpQzBDqvymCoPnzVeg2S3sW2phcgmpF
vYB5rBkXORXBos4NmkMNelY8YWnJG00G5Vfj3GcGxas2qUp9ajR9VaOLa4uE1r1G
tDp6Mwc5S6i2cITN4wGSB33lcU6iZBBV/JfaIgEoQm95j4UN/xn/CGoNGc7m93hB
Tza753VTYVhfN0wP8G/5DHUD6JjLxMAumaonFrzsN/Myf5Tgj2ECO/rVllJ5wAt+
O6Mq1ubm9+Vb4q2qvL8muaCFaHIVxR8AeMeVhQZxvQjRMSjauBfZHmVX0xzei1Bm
LrFIaNICDzpb34MXVBRwfvx9wz06+KrBbOLeH9H/PMJyLu2fFH5gvkVxKglXSGah
arkUVKnqHbHQ/pQOLE4jqegLCZevANhMAzVr5QmWTNgR1wZa1k2Dq+qRCmAekI1l
OHRgrbWNoWQfYgk89k34K8A03mELECcuuG5WDibxOWm34EdXVx3SkYuPiLkKoj/E
CvHwuBoGf6kvO5LZDaDi5p4ujRhM/05Ym0jhFBlH7JuMz8rnkqNwhRmtQKDVeqSe
LET/NftR/Ag=
=4ewr
-----END PGP SIGNATURE-----

--=-fkP8o/dOpkH03xihlF3O--
