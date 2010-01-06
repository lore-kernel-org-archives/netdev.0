From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Wed, 06 Jan 2010 10:49:29 +0100
Message-ID: <1262771369.9474.80.camel@jdb-workstation>
References: <20100105155047.13309.79610.stgit@firesoul.comx.local>
	 <4B4427CE.1040203@gmail.com>
Reply-To: hawk@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:52959 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932098Ab0AFJop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 04:44:45 -0500
In-Reply-To: <4B4427CE.1040203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-01-06 at 07:03 +0100, Eric Dumazet wrote:
> Le 05/01/2010 16:50, Jesper Dangaard Brouer a =C3=A9crit :
> > This is to be used together with switch technologies, like RFC3069,
> > that where the individual ports are not allowed to communicate with
> > each other, but they are allowed to talk to the upstream router.  A=
s
> > described in RFC 3069, it is possible to allow these hosts to
> > communicate through the upstream router by proxy_arp'ing.
> >=20
>=20
> Reading RFC 3069, I dont understand why it needs support on hosts
> themselves.

They don't, this patch does NOT implement support on the hosts (most of
the "hosts" in our ISP setup is peoples Windows machines).
This is intended only to be used on the router.


> > This patch basically allow proxy arp replies back to the same
> > interface (from which the ARP request/solicitation was received).
>=20
> Could you give me an example of how it is used ?

Okay, that first requires an understanding of our setup, then how we us=
e
it...

As an ISP we use this stuff on our Linux based Internet routers (these
boxes are Ethernet Layer 2 connected via VLANs to the Ethernet switches
in the customers apartment buildings).
Our primary customers are entire apartment buildings, where we basicall=
y
establish an Ethernet based network, which all apartments are connected
to.

One big Ethernet based network gives a lot of problems with people
misbehaving, viruses, broadcast packets and so on.  Thus, to solve thes=
e
issues we shield every customer/ethernet-port from each other, by using
RFC 3069 like switch technologies.

This seemed like a good solution, until customers started to run e.g.
web-servers on their home PCs.  This meant that the entire Internet
could browse their homepage, but they could not show it to their
neighbor...

This patch solved the issue by doing proxy arp'ing on the router agains=
t
the "local" network, thus making it possible for customers to
communicate, but via the router.  This also gives the ability to do
firewalling on the router between customers on an Ethernet. (In our
solution the Linux router also have a personal firewall configurable pe=
r
customer.)

It is simply enabled on an interface via e.g.:

 echo 1 > /proc/sys/net/ipv4/conf/eth2.1013/proxy_arp_pvlan

Hope that helps your understand the idea and usage :-)

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

