From: Harald Welte <laforge@netfilter.org>
Subject: Re: Do you know about skb_header_pointer() ?
Date: Thu, 19 Aug 2004 11:44:01 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040819094401.GY3921@sunbeam.de.gnumonks.org>
References: <200408190721.QAA02944@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MdJ3p2aQbVp3YFXz"
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, kisza@securityaudit.hu,
	netfilter-devel@lists.netfilter.org, usagi-core@linux-ipv6.org,
	netdev@oss.sgi.com, David Miller <davem@redhat.com>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Content-Disposition: inline
In-Reply-To: <200408190721.QAA02944@toshiba.co.jp>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--MdJ3p2aQbVp3YFXz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[Cc'ing davem]

On Thu, Aug 19, 2004 at 04:21:19PM +0900, Yasuyuki Kozakai wrote:

> According to a message in "netdev" mailing list, skb_header_pointer() wil=
l be
> introduced in mainline kernel. (see attached message)

yes, David Miller did so. =20

If I remember correctly, his reasoning for skb_header_pointer() was that
even though we are not guaranteed a completely linear transport layer
header, it doesn't really happen at any point in the network stack at
this time.

I personally still like Yasuyuki's implementation[1] better, especially as
long as I'm not convinced that even in the event of IPv6 extension
headers, tunnels, ipsec, whaetever we're can still assume that
everything up to (and including) tcp option headers is linear.

And I still owe Dave some profiles on whether skb_header_pointer() as
opoosed to skb_copy_bits() actually still shows up in the profiles or not.

I'll do this _right now_ before some customer starts to annoy me again
with some stupid problem ;)

> If I remember correctly, this approach was rejected in the result of our
> discussions. And I sent a patch to this mailing list at 2004/08/08.

Yes, I thought your approach is better ;)  But maybe I'm just
overgeneralizing or trying to be too perfect.  Anyway, in the end it's
Dave's call.

[1]
http://lists.netfilter.org/pipermail/netfilter-devel/2004-August/016277.html

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--MdJ3p2aQbVp3YFXz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBJHZhXaXGVTD0i/8RAjF7AJ9kc+PqF3NCP29LkJY8+A2+iaTwPACfQc/C
cU/CU1EeTYEbrZcwb3w32L4=
=0fpc
-----END PGP SIGNATURE-----

--MdJ3p2aQbVp3YFXz--
