From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH 3/5] tcp/dccp: Consolidate common code for RFC 3390
	conversion
Date: Wed, 01 Sep 2010 09:05:23 +0200
Message-ID: <3679BD73-A7A2-415F-A508-AD12F3AFF0AD@comsys.rwth-aachen.de>
References: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1283145794-5615-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1283145794-5615-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1283145794-5615-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <alpine.DEB.2.00.1008301557590.31318@wel-95.cs.helsinki.fi>
 <20100901052355.GA5379@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-7-74845882
Content-Transfer-Encoding: 7bit
Cc: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:57751 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751383Ab0IAHFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 03:05:21 -0400
In-reply-to: <20100901052355.GA5379@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-7-74845882
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=us-ascii

Hi Gerrit,

Am 01.09.2010 um 07:23 schrieb Gerrit Renker:

> | > This patch consolidates initial-window code common to TCP and =
CCID-2:
> | >  * TCP uses RFC 3390 in a packet-oriented manner (tcp_input.c) and
> | >  * CCID-2 uses RFC 3390 in packet-oriented manner (RFC 4341).
> ...
> | > +static inline u32 rfc3390_bytes_to_packets(const u32 smss)
> | > +{
> | > +	return smss <=3D 1095 ? 4 : (smss > 1460 ? 2 : 3);
> | > +}
> | > +
> ...
> |=20
> | What is spelled out in tcp_select_initial_window might also need to =
follow=20
> | the same logic?
> |=20
> Thank you for paying attention, can you please have a look at the =
subsequent
> patch. I went through this yesterday and found that in 4 different =
places=20
> there are 4 different interpretations of what RFC 3390 means.
>=20
> Having asked someone more familiar with IETF issues, it seems that the =
RFC 5681
> interpretation of RFC 3390 is now the 'official' one.
>=20
> =
+------------+--------------------+--------------------+------------------=
--+--------------------+
> | Condition  |     RFC 2414       |        Linux       |       Linux   =
     |     RFC 5681       |
> |            |     RFC 3390       |      tcp_input     |     =
tcp_output     |                    |
> =
+------------+--------------------+--------------------+------------------=
--+--------------------+
> | 2 segments | 2190 < MSS         | 1460 < MSS         | 4380 < MSS    =
     | 2190 < MSS         |
> | 3 segments | 1095 < MSS <=3D 1460 | 1095 < MSS <=3D 1460 | 1460 < =
MSS <=3D 4380 | 1095 < MSS <=3D 2190 |

                              ^^^^^

Are you sure about this?

RFC3390 says (page 2):
 If (1095 bytes < MSS < 2190 bytes) then win <=3D 4380;

So, IMO it should be 1095 < MSS < 2190 for 3 segments, and 2190 <=3D MSS =
for 2 segments
in the "RFC 3390" column.

BTW: I think that we should not reference RFC2414, since RFC3390 =
obsoletes it.

Alex


> | 4 segments |        MSS <=3D 1095 |        MSS <=3D 1095 |        =
MSS <=3D 1460 |        MSS <=3D 1095 |
> =
+------------+--------------------+--------------------+------------------=
--+--------------------+
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22221
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-7-74845882
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (Darwin)

iEYEARECAAYFAkx9+zMACgkQdyiq39b9uS7bYwCfZLh3gBw368knZDBdh/Z0Rt4+
9MoAnRJ/AYomX17hDynl5lCng2O8N7GE
=FRfy
-----END PGP SIGNATURE-----

--Apple-Mail-7-74845882--
