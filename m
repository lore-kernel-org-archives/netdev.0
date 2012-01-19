From: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Subject: RE: route problem
Date: Thu, 19 Jan 2012 11:23:39 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2058B03E5@XMB-BGL-419.cisco.com>
References: <B97B134FACB2024DB45F524AB0A7B7F2058B01D4@XMB-BGL-419.cisco.com><1326878864.2316.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC><B97B134FACB2024DB45F524AB0A7B7F2058B020A@XMB-BGL-419.cisco.com><1326881723.2316.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120118202909.8a3d6963.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Bill Fink" <billfink@mindspring.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-2.cisco.com ([72.163.197.26]:13507 "EHLO
	bgl-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab2ASFxs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 00:53:48 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20120118202909.8a3d6963.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
=46rom: Bill Fink [mailto:billfink@mindspring.com]=20
Sent: Thursday, January 19, 2012 6:59 AM
To: Eric Dumazet
Cc: Prashant Batra (prbatra); netdev@vger.kernel.org
Subject: Re: route problem

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
[Prashant] Yes both IPs are present on the same machine but on differen=
t interfaces.
> local 192.168.101.10 from 192.168.101.101 dev lo  src 192.168.101.10=20
>     cache <local,src-direct>  iif eth1

> local 192.168.101.20 from 192.168.101.101 dev lo  src 192.168.101.20=20
>     cache <local,src-direct>  iif eth1

And since his gateway is 192.168.101.10, an apparently local
IP address, that would probably explain the direct ARPS for
172.16.60.*.

[Prashant] So is this the correct behavior? What my original intention =
was to capture the packets from the=20
interface acting as gateway. So with this behavior I will not be able t=
o capture the packets as 172.16.60.* are not=20
present on the local machine, and it will not get any ARP response.
Consider the gateway on a different machine, in which case ARP request =
will go for gateway IP, and local machine will=20
get the ARP response and send the packets to gateway.

Regards,
Prashant
						-Bill
