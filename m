From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 14 Jun 2006 14:55:24 +0200
Message-ID: <1150289724.26181.74.camel@localhost.localdomain>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zQuoNib1qndQf+Q3yMPT"
Cc: hawk@diku.dk, russell-tcatm@stuart.id.au, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex001a.cxnet.dk ([195.135.216.13]:27847 "EHLO
	comxexch01.comx.local") by vger.kernel.org with ESMTP
	id S964900AbWFNMz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 08:55:26 -0400
To: hadi@cyberus.ca
In-Reply-To: <1150286766.5233.15.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-zQuoNib1qndQf+Q3yMPT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Wed, 2006-06-14 at 08:06 -0400, jamal wrote:

> Russell's site is inaccessible to me (I actually think this is related
> to some DNS issues i may be having)=20

Strange, I have access to Russell's site.  Maybe its his redirect
feature that confuses your browser, try:
 http://ace-host.stuart.id.au/russell/files/tc/tc-atm/

> and your masters is too long to
> spend 2 minutes and glean it; so heres a question or two for you:

Yes, I is quite long and very detailed.  But it worth reading (... says
the author him self ;-))


> - Have you tried to do a long-lived session such as a large FTP and=20
> seen how far off the deviation was? That would provide some interesting
> data point.

The deviation can be calculated.  The impact is of cause small for large
packets.  But the argument that bulk TCP transfers is not as badly
affected, is wrong because all the TCP ACK packets gets maximum penalty.

On an ADSL link with more than 8 bytes overhead, a 40 bytes TCP ACK will
use more that one ATM frame, causing 2 ATM frames to be send that
consumes 106 bytes, eg. 62% overhead.  On a small upstream ADSL line
that hurts! (See thesis page 53, table 5.3 "Overhead summary").


> - To be a devil's advocate (and not claim there is no issue), where do
> you draw the line with "overhead"?=20
> Example the smallest ethernet packet is 64 bytes of which 14 bytes are
> ethernet headers ("overhead" for IP) - and this is not counting CRC etc.
> If you were to set an MTU of say 64 bytes and tried to do a http or ftp,
> how accurate do you think the calculation would be? I would think not
> very different.

I do think we handle this situation, but I'm not quite sure that I fully
understand the question (sorry).


> Does it matter if it is accurate on the majority of the cases?
> - For further reflection: Have you considered the case where the rate
> table has already been considered on some link speed in user space and
> then somewhere post-config the physical link speed changes? This would
> happen in the case where ethernet AN is involved and the partner makes
> some changes (use ethtool).=20
>
> I would say the last bullet is a more interesting problem than a corner
> case of some link layer technology that has high overhead.

We only claim to do magic on ATM/ADSL links... nothing else ;-)


> Your work would be more interesting if it was generic for many link
> layers instead of just ATM.

Well, we did consider to do so, but we though that it would be harder to
get it into the kernel.

Actually thats the reason for the defines:
 #define	ATM_CELL_SIZE		53
 #define	ATM_CELL_PAYLOAD	48

Changing these should should make it possible to adapt to any other SAR
(Segment And Reasembly) link layer. =20


> On Wed, 2006-14-06 at 11:40 +0200, Jesper Dangaard Brouer wrote:
> > The Linux traffic's control engine inaccurately calculates
> > transmission times for packets sent over ADSL links.  For
> > some packet sizes the error rises to over 50%.  This occurs
> > because ADSL uses ATM as its link layer transport, and ATM
> > transmits packets in fixed sized 53 byte cells.
> >=20
> > The following patches to iproute2 and the kernel add an
> > option to calculate traffic transmission times over all
> > ATM links, including ADSL, with perfect accuracy.
> >=20
> > A longer presentation of the patch, its rational, what it
> > does and how to use it can be found here:
> >    http://www.stuart.id.au/russell/files/tc/tc-atm/
> >=20
> > A earlier version of the patch, and a _detailed_ empirical
> > investigation of its effects can be found here:
> >    http://www.adsl-optimizer.dk/
> >=20
> > The patches are both backwards and forwards compatible.
> > This means unpatched kernels will work with a patched
> > version of iproute2, and an unpatched iproute2 will work
> > on patches kernels.
> >=20
> >=20
> > This is a combined effort of Jesper Brouer and Russell Stuart,
> > to get these patches into the upstream kernel.
> >=20
> > Let the discussion start about what we need to change to get this
> > upstream?
> >=20
> > We see this as a feature enhancement, as thus hope that it can be
> > queued in davem's net-2.6.18.git tree.
> >=20
> > ---
> > Regards,
> >  Jesper Brouer & Russell Stuart.
> >=20
>=20

Thanks for your comments :-)

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk


--=-zQuoNib1qndQf+Q3yMPT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEkAc8wuVH+NB3fZkRAlFFAJ0fmu4Nck39z7UsvsHnqbguES12SACfRhJF
Ha75EB8QkktH+GD6IVZFPwM=
=DnWr
-----END PGP SIGNATURE-----

--=-zQuoNib1qndQf+Q3yMPT--

