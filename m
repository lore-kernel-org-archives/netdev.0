From: Jeroen Massar <jeroen@unfix.org>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 18:59:07 +0100
Message-ID: <43947FEB.7020504@unfix.org>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF7D0EA1DAD78D7E7E164B4A7"
Cc: Ben Greear <greearb@candelatech.com>, Al Boldi <a1426z@gawab.com>,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Marc Singer <elf@buici.com>
In-Reply-To: <20051205174010.GA14101@buici.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF7D0EA1DAD78D7E7E164B4A7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Marc Singer wrote:
> On Mon, Dec 05, 2005 at 09:01:00AM -0500, John W. Linville wrote:
>> On Sat, Dec 03, 2005 at 10:33:32AM -0800, Ben Greear wrote:
<SNIP>
>> The association between IP addresses and links is already a bit murky.=

>> Reference the arp_announce sysctl for what I mean.  I recall Dave M.
>> emphasizing on at least one occassion that IP addresses belong to
>> the _box_, not to the link.
>
> Precisely the case.  It should be the case that a box response to an
> arp on *any* interface for *any* IP address known to the box.

Thus you have the following nice setup:

10.100.10.0/24 =3D 10Gbit streaming network
10.100.20.0/24 =3D 10mbit admin network

10.100.10.1 on eth0
10.100.20.1 on eth2

Then some idiot misconfigures his client box, putting 10.100.10.42/24 on
the NIC that is supposed to be in the admin network only.
Suddenly your 10mbit link is full because the arp's get answered on this
link.

I wonder how many RFC's it violates. An interface must only answer ARP's
on the interface that it is configured on, not anything else.

There is a low level of brokeness here already. When you have:

eth0 =3D 10.100.10.1/24
eth1 =3D 192.168.1.1/24
default route towards 192.168.1.250, forwarding enabled.
SMTP on 192.168.1.1.
Now when a client from 10.100.10.5 contacts 192.168.1.1, the FORWARD
chain of iptables is skipped. The packet directly comes into INPUT.
Blocking based on the decision that it is actually being forwarded is
impossible because of this, unless you do -i eth0 -d 192.168.1.1.

Combine this with the above and you can suddenly access internal IP's
when the firewall is configured correctly to block FORWARD's from the
eth1 interface and you have an internal service on 10.100.10.1. You only
have to find a way to be local on the external interface so that you can
do arp's for internal IP's. It will be loved by pesky ISP's who limit
people and disallow them to do NAT of course.

Greets,
 Jeroen


--------------enigF7D0EA1DAD78D7E7E164B4A7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (MingW32)
Comment: Jeroen Massar / http://unfix.org/~jeroen/

iD8DBQFDlH/rKaooUjM+fCMRArtuAJ0fkTwY9MweIdlZGc7aJIK2MXA4DgCgulA0
190837evMz1tTvf1ace8PDo=
=hJHT
-----END PGP SIGNATURE-----

--------------enigF7D0EA1DAD78D7E7E164B4A7--
