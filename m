From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Tue, 03 Nov 2009 21:01:33 -0500
Message-ID: <7916.1257300093@turing-police.cc.vt.edu>
References: <5765.1257270611@turing-police.cc.vt.edu> <4AF07024.80103@gmail.com> <4AF08292.7090102@codefidence.com>
            <Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1257300093_3003P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Gilad Ben-Yossef <gilad@codefidence.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ori Finkelman <ori@comsleep.com>
To: =?ISO-8859-15?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:48462 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbZKDCBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 21:01:49 -0500
In-Reply-To: Your message of "Tue, 03 Nov 2009 23:34:19 +0200."
             <Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1257300093_3003P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Tue, 03 Nov 2009 23:34:19 +0200, Ilpo J=C3€rvinen said:

> On Tue, 3 Nov 2009, Gilad Ben-Yossef wrote:
>=20
> > Eric Dumazet wrote:
> >=20
> > > Valdis.Kletnieks=40vt.edu a =E9crit :
> > >  =20
> > > > Seen right after I started 'fetchmail'.  Reproducible - 3 out of =
3.
> > > > I'll bisect this tonight if nobody jumps up and yells they know w=
hat it
> > > > is...
> > > >    =20
> > Bah... this is most probably my fault. Sorry about that.
> >=20
> > Can you please try the patch in the next email?

Tried while at home, machine panic'ed.  No netconsole here at the moment,=
 sorry.

> > But also, can you please send me the route table in effect when this =
happened
> > and the fetchmail command line/config (removing any passwords or acco=
unt
> > details of course)? I want to understand better when this happens.

% route -n -A inet
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use I=
face
128.173.12.0    0.0.0.0         255.255.252.0   U     0      0        0 e=
th0
0.0.0.0         128.173.12.1    0.0.0.0         UG    0      0        0 e=
th0
% route -n -A inet6
Kernel IPv6 routing table
Destination                                 Next Hop                     =
           Flags Metric Ref    Use Iface
::1/128                                     ::                           =
           U     0      687       1 lo
2001:468:c80:2103:215:c5ff:fec8:334e/128    ::                           =
           U     0      53533       1 lo
2001:468:c80:2103::/64                      ::                           =
           UA    256    316       0 eth0
fe80::215:c5ff:fec8:334e/128                ::                           =
           U     0      176       1 lo
fe80::218:deff:fe9c:24e0/128                ::                           =
           U     0      0        1 lo
fe80::/64                                   ::                           =
           U     256    0        0 eth0
fe80::/64                                   ::                           =
           U     256    0        0 wlan0
ff02::1/128                                 ff02::1                      =
           UC    0      451       0 eth0
ff00::/8                                    ::                           =
           U     256    0        0 eth0  =20
ff00::/8                                    ::                           =
           U     256    0        0 wlan0 =20
::/0                                        fe80::20f:35ff:fe3e:d41a     =
           UGDA  1024   2082       1 eth0

Command line was just 'fetchmail'. Relevant .fetchmailrc:

set postmaster =22valdis=22
set bouncemail
set no spambounce
set properties =22=22
set daemon 240
poll imap.vt.edu with proto IMAP and options
  user 'valdis' there with password 'redacted' is 'valdis' here ssl fetch=
sizelimit 0 smtpaddress turing-police.cc.vt.edu

(imap.vt.edu is 198.82.183.77 - so off the local subnet)

> According to the stacktrace, it came from ipv6 side which doesn't have =
any=20
> null checking what so ever atm (you only handled ipv4 correctly). ...Yo=
u=20
> should be a bit more careful next time when adding any BUG_ONs...

Why was this blowing chunks in the IPv6 when I was making an IPv4 connect=
ion
then? I just noticed that. My fetchmail can't make an IPv6 TCP connection=
 to
our IMAP server because the server isn't v6-enabled yet.  And although I
contact our DNS over IPv6, but that's UDP not TCP.


--==_Exmh_1257300093_3003P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFK8OB9cC3lWbTT17ARAg96AKDWNvY31yc4f2ta0TXVIz/pfEtVlQCg8ZPT
LRXtuYodyYncwg+UDXmLX6U=
=Sk5f
-----END PGP SIGNATURE-----

--==_Exmh_1257300093_3003P--

