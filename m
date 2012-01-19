From: Bill Fink <billfink@mindspring.com>
Subject: Re: route problem
Date: Wed, 18 Jan 2012 20:29:09 -0500
Message-ID: <20120118202909.8a3d6963.billfink@mindspring.com>
References: <B97B134FACB2024DB45F524AB0A7B7F2058B01D4@XMB-BGL-419.cisco.com>
	<1326878864.2316.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<B97B134FACB2024DB45F524AB0A7B7F2058B020A@XMB-BGL-419.cisco.com>
	<1326881723.2316.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Prashant Batra (prbatra)" <prbatra@cisco.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:45940 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753163Ab2ASCeJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 21:34:09 -0500
In-Reply-To: <1326881723.2316.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jan 2012, Eric Dumazet wrote:

> Le mercredi 18 janvier 2012 =E0 15:38 +0530, Prashant Batra (prbatra)=
 a
> =E9crit :
> > 2.6.18 kernel.
> >=20
>=20
> Please dont top post on netdev mailing list
>=20
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> > Sent: Wednesday, January 18, 2012 2:58 PM
> > To: Prashant Batra (prbatra)
> > Cc: netdev@vger.kernel.org
> > Subject: Re: route problem
> >=20
> > Le mercredi 18 janvier 2012 =E0 14:47 +0530, Prashant Batra (prbatr=
a) a
> > =E9crit :
> > > Hi,
> > >=20
> > > I have added a route for an external ip via a gateway which is av=
ailable
> > > on the same machine.
> > > I want to capture the packets going to this external IP using PF_=
PACKET
> > > socket.
> > >=20
> > > #route=20
> > > Destination     Gateway         Genmask         Flags Metric Ref =
   Use
> > > Iface
> > > 192.168.101.0   *               255.255.255.0   U     0      0   =
     0
> > > eth1
> > > 172.16.60.0     192.168.101.10  255.255.255.0   UG    0      0   =
     0
> > > eth1
> > >=20
> > > So, when a packet is sent to 172.16.60.*, kernel should send arp =
request
> > > for this gw IP 192.168.101.10. As gw IP is locally reachable,=20
> > > It should send its mac address in arp-response and kernel should =
send
> > > the packet via that interface.
> > >=20
> > > But what I am seeing is that instead of asking the gateway IP, ke=
rnel
> > > sends a arp request for destingation ip(172.16.60.*)
> > >=20
> > > #tcpdump -I eth1
> > > 04:12:45.334966 arp who-has 172.16.60.2 tell 192.168.101.20
> > > 04:12:46.334839 arp who-has 172.16.60.2 tell 192.168.101.20
> > > 04:12:48.334584 arp who-has 172.16.60.2 tell 192.168.101.20
> > > 04:12:49.334457 arp who-has 172.16.60.2 tell 192.168.101.20
> > > 04:12:50.335329 arp who-has 172.16.60.2 tell 192.168.101.20
> > > 04:12:52.335075 arp who-has 172.16.60.2 tell 192.168.101.20
> > > 04:12:53.334947 arp who-has 172.16.60.2 tell 192.168.101.20
> > > 04:12:54.334821 arp who-has 172.16.60.2 tell 192.168.101.20
> > >=20
>=20
> This comes from another machine, since your eth1 addr is 192.168.101.=
10

Actually, if I'm interpreting the "ip route list cache" output
correctly, it appears it has local IP addresses of both 192.168.101.10
and 192.168.101.20.

> local 192.168.101.10 from 192.168.101.101 dev lo  src 192.168.101.10=20
>     cache <local,src-direct>  iif eth1

> local 192.168.101.20 from 192.168.101.101 dev lo  src 192.168.101.20=20
>     cache <local,src-direct>  iif eth1

And since his gateway is 192.168.101.10, an apparently local
IP address, that would probably explain the direct ARPS for
172.16.60.*.

						-Bill
