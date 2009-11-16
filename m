From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Mon, 16 Nov 2009 15:18:17 -0500
Message-ID: <4B01B389.9090507@gmail.com>
References: <20091002141407.30224.54207.stgit@dev.haskins.net>	<20091110115335.GC6989@redhat.com>	<4AF919020200005A000586A9@sinclair.provo.novell.com>	<20091110131722.GA19645@redhat.com>	<4AF9747E.8020408@novell.com>	<20091110143652.GB19645@redhat.com>	<4AF98A8C.9040201@novell.com>	<20091114011229.GA18580@gondor.apana.org.au>	<4AFE08EF.2030308@gmail.com>	<20091114022103.GA19020@gondor.apana.org.au>	<4AFE15AD.6000208@gmail.com>	<20091113184503.13f6d447@s6510>	<4AFE3FD2.6030403@gmail.com> <20091116115931.6266f9c9@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCAF29B2210E4E39837024CE9"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Gregory Haskins <ghaskins@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:48730 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831AbZKPUSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 15:18:15 -0500
In-Reply-To: <20091116115931.6266f9c9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCAF29B2210E4E39837024CE9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger wrote:
> On Sat, 14 Nov 2009 00:27:46 -0500
> Gregory Haskins <gregory.haskins@gmail.com> wrote:
>=20
>> Stephen Hemminger wrote:

>=20
>>> People have tried doing copy-less send by page flipping, but the over=
head of the IPI to
>>> invalidate the TLB exceeded the overhead of the copy. There was an In=
tel paper on this in
>>> at Linux Symposium (Ottawa) several years ago.
>> I think you are confusing copy-less tx with copy-less rx.  You can try=

>> to do copy-less rx with page flipping, which has the IPI/TLB thrashing=

>> properties you mention, and I agree is problematic.  We are talking
>> about copy-less tx here, however, and therefore no page-flipping is
>> involved.  Rather, we are just posting SG lists of pages directly to t=
he
>> NIC (assuming the nic supports HIGH_DMA, etc).  You do not need to fli=
p
>> the page, or invalidate the TLB (and thus IPI the other cores) to do
>> this to my knowledge.
>>
>=20
> If you want to do copy-less tx for all applications, you have to
> do COW to handle the trivial case of :
>=20
> while (cc =3D read(infd, buffer, sizeof buffer)) {
>    send(outsock, buffer, cc);
> }
>=20
>=20

You certainly _could_ implement this as a COW I suppose, but that would
be insane.  If someone did do this, you are right: you need TLB
invalidation.

However, if I were going to actually propose the changeover of the
system calls to use zero-copy (note that I am not), it would be based on
the concept in this patch.  That is: the send() would block until the
NIC completes the DMA and the shinfo block is freed.  Alternate
implementations would be AIO based, where the shinfo destructor
signifies the generation of the completion event.

FWIW: The latter is conceptually similar to how this is being used in
AlacrityVM.

HTH

Kind Regards,
-Greg


--------------enigCAF29B2210E4E39837024CE9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksBs4kACgkQP5K2CMvXmqETQACfeydFUnIJYpjoIrLpDM+eQGMA
p60An09PbHED3QzdR+Ri5+/N1uQTwbux
=7M4I
-----END PGP SIGNATURE-----

--------------enigCAF29B2210E4E39837024CE9--
