From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail
Date: Mon, 16 Aug 2004 09:20:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816072032.GH15418@sunbeam2>
References: <411C0FCE.9060906@crocetta.org> <1092401484.1043.30.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/hzbcv1ZPoZ/SOgH"
Cc: sandr8@crocetta.org, devik@cdi.cz, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1092401484.1043.30.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--/hzbcv1ZPoZ/SOgH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[removing lots of people from the Cc, since they are definitely on
 netdev and don't need to be Cc'ed at this state]

Hi Jamal!

On Fri, Aug 13, 2004 at 08:51:24AM -0400, jamal wrote:
> Alessandro,
>=20
> This summary applies to all your patches: Too many changes that seem
> unnecessary. Take a deep breath.

I'm actually not as pessimistic about all his changes.

Allesandro's ultimate goal seems to be connection-based accounting that
accounts precisely which packets have actually hit the outgoing wire.
While I'm quite happy with the now in-kernel conntrack accounting
(basedo on Rx rather than Tx packets/bytes), this is a different
definition of accounting.

Let's discuss the individual patches seperately.

1) Is certainly not a huge issue, no debate here

2) I am not as familiar with the tc/scheduler code as you are, but I
also think that what he is trying to achieve is a valid goal.  He tries
to make all tc-related packet drops go to a single code path for packet
dropping.  Independent of Allesandro's implementation, I would really
like to see something like this.   We once had an experimental patch
called the 'dropped hook' that would be traversed for all packets
dropped somewhere in the stack (for auditing in userspace, whatever).
Having a single packet drop point makes such a change less intrusive.

3) Is already in davem's tree, no need for discusion ;)

4) This is the part you are complaining about, right?  I agree, I don't
like conntrack specific stuff in dev.c and packet scheduler areas.

> cheers,
> jamal

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--/hzbcv1ZPoZ/SOgH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBIGBAXaXGVTD0i/8RAs5RAJ0b+wYGtfWAoYaj4cAhJ17kO1ufTwCfSPH2
DjWXbTzwa6cEmfcVnOmBFS8=
=PXbM
-----END PGP SIGNATURE-----

--/hzbcv1ZPoZ/SOgH--
