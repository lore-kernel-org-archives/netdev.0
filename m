From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Wed, 8 Sep 2004 22:51:38 +0300
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <200409082251.45771.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <1094628909.1097.145.camel@jzny.localdomain> <413F2D33.1000508@atheros.com>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1193371.lcs05vS5TV";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
 acx100-devel@lists.sourceforge.net,
 greg chesson <greg@atheros.com>,
 hadi@cyberus.ca,
 jgarzik@pobox.com,
 jkmaline@cc.hut.fi,
 prism54-devel@prism54.org,
 sam@errno.com,
 vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: netdev@oss.sgi.com
In-Reply-To: <413F2D33.1000508@atheros.com>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--nextPart1193371.lcs05vS5TV
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Greg,
you missed one important point. Besides data packets, that every driver now=
=20
convert .11<->.3 using almost the same code, there is whole story of=20
management. Many modern cards are "softmac" and do all management on host. =
I=20
see no point for every driver to implement its own scanning and association=
=2E=20
It is simply waste of resources.

To make step forward, I suggest the following:

1. Dave's code is at least year old. someone need to start maintain it,=20
starting with update for current kernel infrastructure. Get it compile and=
=20
load for 2.6.9, for example.

2. To debug stack, you don't need real driver. I can write dummy .11 driver=
=20
that will silently discard all Tx, and will provide some way for user level=
=20
tool to simulate Rx (ioctl, netlink, does not really matter). For logic, it=
=20
is sufficient. Later, when it will come to timing, performance etc, it will=
=20
be easy to strip some real driver.

This may be king of "proof of concept".

Vladimir

On Wednesday 08 September 2004 19:02, greg chesson wrote:
gc> You guys are too serious and, I believe, missed the real points.
gc>
gc> 1.  There is a need in the OS for a "service" to convert between
gc>        .11 and .3 packet formats.   It should be designed for
gc> hw-independence.
gc>       Everyone sees the same potential for unification
gc>        of wireless drivers.
gc>
gc> 2.  It's harder to do than it first appears because the complete
gc>       transformation from .3 to .11 cannot be done in isolation
gc>       from the driver(s) and there are monkey wrenches that get
gc>       tossed in from crypto, interaction between crypto and
 fragementation, gc>       power-save, observing txoplimits, and other thin=
gs
 that tend gc>       to cross architecture lines that would otherwise be ni=
ce
 and clean. gc>
gc> 3.  I personally don't have religion about whether a service
gc>       that transforms headers is implemented as a stack or implemented
gc>       as a side call.   I think that a variety of factors are worth
gc> considering.
gc>       In this particular case (header transformation), I believe a side
 call gc>       "helper function" is appropriate and has less overhead than
 the full gc>       protocol stack mechanism.   But it's pointless to argue
 about it gc> without
gc>       measurements.
gc>
gc> 4.  David's skeleton code is quite interesting and a good start.
gc>        You won't know its usefulness until someone tries to implement
gc>       a real driver.
gc>
gc> g
gc>
gc>
gc>
gc> jamal wrote:
gc> > On Tue, 2004-09-07 at 13:10, David S. Miller wrote:
gc> >
gc> >>On Tue, 07 Sep 2004 10:03:41 -0700
gc> >>greg chesson <greg@atheros.com> wrote:
gc> >>
gc> >>
gc> >>>What about eth_type_trans()?
gc> >>
gc> >>It determines the protocol type from the ethernet header
gc> >>fields.  It is a simple shorthand header field fetcher,
gc> >>not a protocol stack.
gc> >>
gc> >>You would need a eth80211_type_trans() for wireless
gc> >>drivers too, and surprise surprise my skeleton 802.11
gc> >>stack code in fact does exactly this.
gc> >
gc> >
gc> > Or as Andi has been suggesting for sometime, not invoke it all ;->
gc> > This is possible if the DMA descriptor already has all the info
gc> > needed (quiet a few modern hardware can be programmed to do this).
gc> > .. er, at the driver level. So this is not "a gross input packet
gc> > hooked eater thing that's an ugly wart bolted onto the
gc> > side of the driver API.";->
gc> >
gc> > cheers,
gc> > jamal
gc> >
gc> >
gc> >
gc>
gc>
gc>
gc>

--nextPart1193371.lcs05vS5TV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBP2LRqxdj7mhC6o0RAi+gAKCtXlLW+VfAKBKgAI9zZJGInw1dXgCeJ4LB
AdJQCCWxTrYNzMlF5N936m8=
=w07b
-----END PGP SIGNATURE-----

--nextPart1193371.lcs05vS5TV--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
