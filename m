From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 3 Aug 2010 14:40:44 +0100
Message-ID: <20100803134044.GR11110@cel.leo>
References: <20100802201629.GA5973@nuttenaction>
 <20100802.221813.43045517.davem@davemloft.net>
 <20100803070709.GO11110@cel.leo>
 <20100803.001904.63020040.davem@davemloft.net>
 <6809423e656a160df11216ea5acc3d8b@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vimm9O0gM1Jj7bTP"
Cc: David Miller <davem@davemloft.net>
To: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:41156 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756549Ab0HCNkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 09:40:45 -0400
Content-Disposition: inline
In-Reply-To: <6809423e656a160df11216ea5acc3d8b@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vimm9O0gM1Jj7bTP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 03, 2010 at 11:10:28AM +0200, Hagen Paul Pfeifer wrote:
> >> Rightnow, BPF is all but useless for parsing, say, IPv6. I only pick
> >> IPv6 as one example, I'm sure there must exist a great number more
> >> packet-based protocols that use a "linked-list" style approach to
> >> headers. None of those are currently filterable on the current set of
> >> instructions. LOOP would allow these.
> >=20
> > It's not meant for detailed packet protocol header analysis,
> > it's for stateless straight line matching of masked values
> > in packet headers.
>=20
> David is right, BPF cannot - and will not - keep with any high level
> connection tracking packet filter. There is an processing trade-off betwe=
en
> packet classification and packet storage with post processing analysis.

This has nothing to do with high-level connection tracking.

I want to accept all (IPv4 or IPv6) TCP packets concerning port 80.
That's all. No connection tracking. Simply a "stateless straight line
matching of masked values in packet headers". Namely, the TCP source or
destination ports, being 80.=20

Should BPF be allowed to implement such a filter?

This is the core question.

If yes, then we either need LOOP, or alternatively my SKF_AD_TRANSPROTO
/ SKF_TRANS_OFF idea (see the other thread fork). Without either LOOP or
TRANSPROTO, it becomes next-to-impossible to -find- the TCP header in an
IPv6 packet, and hence make filtering decisions based on it.

If no, please justify what BPF -is- for then, given that right now
applications like tcpdump/libpcap already use it for this very purpose.
Please further justify why BPF has the "LDX MSH" instruction

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--vimm9O0gM1Jj7bTP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMWBxcvLS2TC8cBo0RAjzUAKD2vb3HpEuAB3EVGM/UmP2APB2ppACeLo9E
0vDo9PK8hNw5u4wlCB+DLjg=
=VIAL
-----END PGP SIGNATURE-----

--vimm9O0gM1Jj7bTP--
