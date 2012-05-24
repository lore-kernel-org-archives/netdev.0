From: Antonio Quartulli <ordex@autistici.org>
Subject: arp.c: external usage
Date: Thu, 24 May 2012 18:07:16 +0200
Message-ID: <20120524160715.GC6454@ritirata.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZwgA9U+XZDXt4+m+"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:56839 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab2EXQGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 12:06:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZwgA9U+XZDXt4+m+
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I'm writing here because we, as batman-adv developers, wanted to add a new
feature called D.A.T. (Distributed ARP Table) to the batman-adv module, but=
 we
encountered some issues.

Going into the details, DAT is a DHT (Distributed Hash Table) based ARP cac=
he and
for its purposes it requires a local storage for classic ARP entries. In or=
der
to avoid code duplication, we decided to "consistently" use the local ARP t=
able
provided by the kernel.

These are the operations we wanted to perform on the kernel ARP table:
- Add a new entry
- Check if an entry is present
- Change the default entry timeouts

The code we provided used the following functions provided by the ARP/neigh=
bour
layer API:

- neigh_lookup()
- neigh_release()
- arp_create()

Other than that the code was (necessarily) using "arp_tbl" and was modifyin=
g the
timeouts by directly accessing members of "(struct in_device)->arp_parms".

The patches adding the feature has been rejected by David Miller because he
stated that the ARP/neighbour code is going to be heavily modified and for =
this
reason he wanted to avoid to add other code depending on those components.

You find the emails where David rejected our code here:
https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2012-April/006921.html
https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2012-May/006925.html


The last email from David stated that we must not use ARP/neighbour layer
internals, but all the functions we are using are correctly exported by the
ARP/neigh layer and so are part of the API that we are using.

At this point we are stuck and we don't know how to proceed.
=46rom David's last
email I personally got the impression that we should not use the ARP/neigh =
layer
at all and so we should implement our own ARP backend (which means duplicat=
ing a
lot of code). However this does not sound like a good solution.

If changes for the ARP/neigh layer are already planned, is it possible to k=
now
whether we will be able to perform the aforementioned operations by means o=
f the
new API? Or, do you have any suggestion on how to perform the needed operat=
ions
without directly touching the ARP/neigh layer?


Thank you in advance,
	Best Regards



--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--ZwgA9U+XZDXt4+m+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJPvlyzAAoJEFMQTLzJFOZFNugIALkRV/iXzD8phfpCDahgdnaq
4OeG4ajtf/Qa4TJE4Y8w1YlV/za9pWCvgpkWq74zQQHhxDVg/I1IZI3HEm3jBrqd
ALN8l+WPZMV6z0zFcrydGf05BcTJomC9ClJJkQgcsZM3Fp8t7sbY77EP5gFJqN0O
to6xFtmcRgvN5Z9lA5ndHOKjCg8xfUfDz19qv7ICXa+iJjD9phUlQ0uDSVs9JcaG
j9kizoe+saL4fcBA+MQ10eeX1u2eIgqujchiEPDA/JyT0APQCx06e9hjmbOTMGZZ
dwgbCTJW16ifFVoGyIn2CeGaxwsU83k4hCpYPh7tCpnhABZdavqt+D/OpqEwOjU=
=zaiC
-----END PGP SIGNATURE-----

--ZwgA9U+XZDXt4+m+--
