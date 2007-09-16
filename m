From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: Please pull 'adm8211' branch of wireless-2.6
Date: Sun, 16 Sep 2007 00:47:40 -0400
Message-ID: <200709160047.45128.flamingice@sourmilk.net>
References: <20070915132220.GE6060@tuxdriver.com> <200709152017.02646.flamingice@sourmilk.net> <46EC7F33.2050206@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5199460.uWAHHEJ5x5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:43496 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750729AbXIPEsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 00:48:09 -0400
In-Reply-To: <46EC7F33.2050206@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5199460.uWAHHEJ5x5
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 15 September 2007 20:56, Jeff Garzik wrote:
> >>> +	if (flags & IFF_PROMISC)
> >>> +		dev->flags |=3D IEEE80211_HW_RX_INCLUDES_FCS;
> >>> +	else
> >>> +		dev->flags &=3D ~IEEE80211_HW_RX_INCLUDES_FCS;
> >>
> >> why does promisc dictate inclusion of FCS?
> >
> > Because that's the way the hardware works.
>
> Why not always include it, regardless of promisc?
>
I really do mean that's how the hardware works. If you turn on the promisc =
bit=20
in the hardware (which IFF_PROMISC causes), it starts including the FCS, bu=
t=20
if the bit is not set, the FCS is not included in frames.

> >>> +	} while (count++ < 20);
> >>
> >> NAK -- talk about back to the past.
> >>
> >> It's bogus to loop in the interrupt handler, then loop again in both RX
> >> and TX paths.  You are getting close to reinventing the wheel here.
> >>
> >> Use NAPI rather than doing such a loop.
> >
> > This is old interrupt handler code from Jouni's original driver. I never
> > bothered to replace it with the simpler designs used in newer drivers
> > I've worked on.
> >
> > Also - mac80211 drivers have no access to NAPI.
>
> Not true as of net-2.6.24.
>
Huh? How does a driver use NAPI if it can't pass a struct net_device?

> >>> +/* CSR (Host Control and Status Registers) */
> >>> +struct adm8211_csr {
> >>
> >> [snip]
> >>
> >>> +} __attribute__ ((packed));
> >>
> >> attributed(packed) is unneccesary here, and its use results in
> >> sub-optimal code
> >
> > How? Doesn't this just turn into a bunch of offsets?
>
> It depends on how its used in the code.
>
I don't think I'm using it in a way that would make a difference.

> >> enums are preferred.  they do not disappear at the cpp stage, and conf=
er
> >> type information.
> >
> > I'd rather not.
>
> Elaboration?
>
What form of debugging are you talking about? I don't see how it makes a=20
difference for debugging. The type checking provided by enums won't make a=
=20
difference for my code - any problems with using the wrong register bits in=
=20
the wrong place is obvious due to the prefixes. I don't really see how enum=
=20
type checking is even effective at all without annotations and casts all ov=
er=20
the place.

Thanks,
=2DMichael Wu

--nextPart5199460.uWAHHEJ5x5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBG7LVxT3Oqt9AH4aERAkzIAJ9j0ux9CG+UKqO7mhueEyzVUKY6LwCfZ/W+
VggYak5MAHQl3ulAf/aBALw=
=dq54
-----END PGP SIGNATURE-----

--nextPart5199460.uWAHHEJ5x5--
