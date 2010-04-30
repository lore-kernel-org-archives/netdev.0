From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: [RFC] BPF program access to transport header
Date: Fri, 30 Apr 2010 23:10:47 +0100
Message-ID: <20100430221047.GA19334@cel.leo>
References: <20100430193916.GZ19334@cel.leo>
 <4BDB3A4D.5020507@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fKtH0JUtvN5p2ETH"
To: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:52922 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756281Ab0D3WKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 18:10:49 -0400
Content-Disposition: inline
In-Reply-To: <4BDB3A4D.5020507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fKtH0JUtvN5p2ETH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 30, 2010 at 10:15:09PM +0200, Patrick McHardy wrote:
> > I forsee a number of issues with trying to provide this:
> >=20
> >  * How to provide the protocol number (e.g. 6 for TCP, 1 for ICMP) to
> >    the BPF program
>=20
> Using one of the registers?

Using, how? What operation would put the numbers in there in the first
place?

I was thinking more of simply providing an ancilliary data area field,
similar to SKF_AD_PROTO and SKF_AD_HATYPE, following along the same
idea.

  LD WORD[SKF_AD_TRANSPROTO]

would then load the A register with the transport protocol number.

> >  * How to obtain the transport offset - AIUI, the skf_transport_offset()
> >    won't actually be set yet by the time the filter program runs.
>=20
> For IPv4 its trivial. For IPv6 you could use ipv6_skip_exthdr().
> A slightly more flexible way would be to use something like the
> netfilter ipv6_find_hdr() function to get the offset of any header
> type. The protocol number could be returned in one of the registers
> (the other one would contain the offset).

I sortof meant in general. I really don't think trying to add
IPv4/IPv6-specific code into net/core/filter.c is going to go down well.

On the other hand, I observe from casual experimentation, that on
receipt of a TCP packet in IPv4 over ethernet, the offets are:

  mac=3D0 network=3D14 transport=3D14

This suggests more work needing to be done somewhere, because I'd expect
for an Ethernet/IPv4/TCP packet to get

  mac=3D0 network=3D14 transport=3D34

> >  * What to do if the underlying protocol doesn't support a transport
> >    layer above it - e.g. ARP.
>=20
> I'd say simply abort the filter.

That sounds reasonable.

Another question occurs:

 * How to obtain the transport protocol number? I can easily provide it
   in the AD area; say as SKF_AD_TRANSPROTO; but how can
   net/core/filter.c know the value?

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--fKtH0JUtvN5p2ETH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFL21VmvLS2TC8cBo0RAkZoAKCSyfESHfC3Q4ogjyuGzwMXMhgRtgCg53Fb
FAz/0AV+uypFk5Wny2N5040=
=b/0B
-----END PGP SIGNATURE-----

--fKtH0JUtvN5p2ETH--
