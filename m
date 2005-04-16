From: Harald Welte <laforge@gnumonks.org>
Subject: (some persisting) troubles with neighbour cache code backport (even) in 2.4.30
Date: Sat, 16 Apr 2005 10:21:00 +0200
Message-ID: <20050416082100.GY25433@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PCSS5jcV3Z4INoC2"
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Netdev List <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--PCSS5jcV3Z4INoC2
Content-Type: multipart/mixed; boundary="84JQvybYWNxrNqac"
Content-Disposition: inline


--84JQvybYWNxrNqac
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I just received this bug report.

I'll try to look into it later today/tomorrow, but just in case somebody
else has thoughts on this, I'm forwarding it.

Thanks!

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--84JQvybYWNxrNqac
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: Received: from ganesha.gnumonks.org ([unix socket])
	by ganesha (Cyrus v2.1.17-IPv6-Debian-2.1.17-0woody.3.1) with LMTP; Wed, 13 Apr 2005 22:19:13 +0200
X-Sieve: CMU Sieve 2.2
Return-path: <rafaj@cedric.unob.cz>
Received: from vishnu.netfilter.org ([213.95.27.115])
	by ganesha.gnumonks.org with esmtp (TLS-1.0:DHE_RSA_3DES_EDE_CBC_SHA:24)
	(Exim 4.34)
	id 1DLoKP-0008L2-HW
	for laforge@gnumonks.org; Wed, 13 Apr 2005 22:19:13 +0200
Received: from cedric.unob.cz ([160.216.40.10])
	by vishnu.netfilter.org with esmtp (Exim 4.41 #1 (Debian))
	id 1DLoPJ-0001Va-2L
	for <laforge@netfilter.org>; Wed, 13 Apr 2005 22:24:20 +0200
Received: from localhost (rafaj@localhost)
	by cedric.unob.cz (8.12.10/8.12.10) with ESMTP id j3DKIuxc005914;
	Wed, 13 Apr 2005 22:19:00 +0200
Date: Wed, 13 Apr 2005 22:18:56 +0200 (MEST)
From: Jan Rafaj <rafaj@cedric.unob.cz>
To: laforge@netfilter.org
Subject: (some persisting) troubles with neighbour cache code backport (even)
 in 2.4.30
Message-ID: <Pine.LNX.4.44.0504132143140.5388-100000@cedric.unob.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Spam-Score: -2.6 (--)
X-Spam-Score: -2.3 (--)


Hi Harald,

First of all, please excuse me for bothering you this way and for
my amusing english (not used to write/speak it everyday).
I'll try to be as brief as possible.

Please note I'm not a programmer (although with certain C skills),
and consider me a joe-blow Linux user (somewhat advanced since I do
linux sysadm work for 10 years). I'm writing this in a hurry, so
it may look horrible, but its better to report than nothing, I guess.



I've recently decided to upgrade to 2.4.30 kernel on one of my routers,
from 2.4.26 it has been running up to now.
All went smoothly, except of one thing:
I suddenly experienced that the router suddenly stopped sending
traffic to its default destination route.
By taking a look at ARP table, everything was OK - specifically,
the gateway IP's ARP record was cached as normal.
I just tried to delete the ARP record for gateway IP - and that
has forced router to elicit ARP query for the peer (which it didnt send
before for a long time), and the traffic was sent to gateway IP again!
However, this state semi-randomly persisted ranging only from several
minutes up to few hours, according to my observation. After that time,
the router again lost the track to gateway IP (and manual deletion
of cached ARP record for the gateway IP was needed again). It occasionally
resurrected itself (after few hours, usually), but then everything
was just repeating with same symptoms. And that circle went for
several days, while I was investigating.

Here, I have to say that the mentioned router has somewhat fairly 'odd'
routing table:
Most (direct, interface) routes are of 'host route' type, added by command
like:

ifconfig eth0 1.2.3.4 pointopoint 5.6.7.8 netmask 255.255.255.255

I know that according to RFCs that shouldnt be (and all that stuff that
says that broadcasting capability is required for ethernet media - indeed
it is, but in '2 endpoints involved' scenario ARP broadcast capability is
really only necessary), but it works, has worked long time ago already and
is still used in some special situations like in my case (assigned small
range of 'public' IPs, and the effort to save as much those precious IPs
for real machines has lead one to use private IPs on router interfaces
pointing to client machines - please consider that also all those 'client'
ethernet links have just two points (the client machine and router
interface).

First I suspected it might be just becouse of old e100 & e1000 drivers,
so I've replaced them (compiled from scratch, of course; I always do
compile everything) with those published directly by INTEL (that helped in
case of 2.4.26, where I had another problem, that just turned out
to be a driver issue).
That didnt help.
As I didnt want to downgrade back to 2.4.26 *just* becouse of
this, I googled a bit more and came by to an 'dual ARP records' issue
someone had reported with 2.4.28. Starting to suspect ARP code,
I just quicky "backported" the original neighbour ARP handling
code from 2.4.26 to 2.4.30 - by editing/replacing following files:

./include/net/neighbour.h
./net/core/neighbour.c
./net/ipv4/arp.c
./net/decnet/dn_route.c
./net/decnet/dn_neigh.c
./net/atm/proc.c
./net/netsyms.c

And that helped!
Now I again see the router asks for gateway IP's ARP in 1min. intervals
again. And no odd 'gateway IP suddenly not responding & router
sends no ARP queries after a minute' anymore.

Please note that I didnt observe this strange problem on other routers
here (already running 2.4.30), that have, however, more 'common' setup
than the one mentioned above (usual routes with commonly used matching
netmasks & broadcast addresses).

Should I investigate more thoroughly (should you want exact reports
from me), please let me know.

Do you think you could look at this issue?

Thanks & best regards,

Jan



--84JQvybYWNxrNqac--

--PCSS5jcV3Z4INoC2
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCYMrsXaXGVTD0i/8RAjqpAJ9P8AoX5tEOq9ZmEsann6bj8iW0lgCdHPmI
+B329uc+gdNnJtFxCnI09nA=
=QIPV
-----END PGP SIGNATURE-----

--PCSS5jcV3Z4INoC2--
