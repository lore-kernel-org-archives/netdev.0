From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Tue, 17 Nov 2009 07:33:47 -0500
Message-ID: <4B02982B.9070004@gmail.com>
References: <4AF98A8C.9040201@novell.com> <20091114011229.GA18580@gondor.apana.org.au> <4AFE08EF.2030308@gmail.com> <20091113.190438.78469912.davem@davemloft.net> <4B016041.5030000@gmail.com> <20091117010238.GA10029@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig14FCFE4AEA081A13D5F2A978"
Cc: David Miller <davem@davemloft.net>, ghaskins@novell.com,
	mst@redhat.com, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752937AbZKQMdr@vger.kernel.org>
In-Reply-To: <20091117010238.GA10029@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig14FCFE4AEA081A13D5F2A978
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Herbert Xu wrote:
> On Mon, Nov 16, 2009 at 09:22:57AM -0500, Gregory Haskins wrote:
>> But really, this is somewhat orthogonal to the original problem, so le=
t
>> me see if we can bring it back on topic.  Michael stated that this pat=
ch
>> in question may be problematic because there are places in the stack
>> that can get_page() without also maintaining a reference to the shinfo=

>> object.  Evgeniy seems to say the opposite.  I am not sure who is righ=
t,
>> or if I misunderstood one or both of them.  Any thoughts?
>=20
> There are loads of places where this can happen.  Start with
> pskb_expand_head.

Indeed, I see your point.  Looks like we can potentially solve that with
an extra level of indirection.  E.g. skb->shinfo->owner, with a
ref-count+callback.  Thoughts?

Kind Regards,
-Greg



--------------enig14FCFE4AEA081A13D5F2A978
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksCmCsACgkQP5K2CMvXmqEBHACfZqq+/JO3jy6r51tAidUP8S5E
pA4AnjnBVnGhT8F4l3nYH9QiG5P6AK0L
=Pu3Q
-----END PGP SIGNATURE-----

--------------enig14FCFE4AEA081A13D5F2A978--
