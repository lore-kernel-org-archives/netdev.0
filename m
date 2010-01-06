From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Wed, 6 Jan 2010 23:22:31 +1030
Message-ID: <20100106232231.5f454d53@opy.nosense.org>
References: <20100105155047.13309.79610.stgit@firesoul.comx.local>
	<4B4427CE.1040203@gmail.com>
	<1262771369.9474.80.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:59024 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202Ab0AFMwn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 07:52:43 -0500
In-Reply-To: <1262771369.9474.80.camel@jdb-workstation>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Jan 2010 10:49:29 +0100
Jesper Dangaard Brouer <hawk@comx.dk> wrote:

> On Wed, 2010-01-06 at 07:03 +0100, Eric Dumazet wrote:
> > Le 05/01/2010 16:50, Jesper Dangaard Brouer a =E9crit :
> > > This is to be used together with switch technologies, like RFC306=
9,
> > > that where the individual ports are not allowed to communicate wi=
th
> > > each other, but they are allowed to talk to the upstream router. =
 As
> > > described in RFC 3069, it is possible to allow these hosts to
> > > communicate through the upstream router by proxy_arp'ing.
> > >=20
> >=20
> > Reading RFC 3069, I dont understand why it needs support on hosts
> > themselves.
>=20
> They don't, this patch does NOT implement support on the hosts (most =
of
> the "hosts" in our ISP setup is peoples Windows machines).
> This is intended only to be used on the router.
>=20
>=20
> > > This patch basically allow proxy arp replies back to the same
> > > interface (from which the ARP request/solicitation was received).
> >=20
> > Could you give me an example of how it is used ?
>=20
> Okay, that first requires an understanding of our setup, then how we =
use
> it...
>=20
> As an ISP we use this stuff on our Linux based Internet routers (thes=
e
> boxes are Ethernet Layer 2 connected via VLANs to the Ethernet switch=
es
> in the customers apartment buildings).
> Our primary customers are entire apartment buildings, where we basica=
lly
> establish an Ethernet based network, which all apartments are connect=
ed
> to.
>=20
> One big Ethernet based network gives a lot of problems with people
> misbehaving, viruses, broadcast packets and so on.  Thus, to solve th=
ese
> issues we shield every customer/ethernet-port from each other, by usi=
ng
> RFC 3069 like switch technologies.
>=20
> This seemed like a good solution, until customers started to run e.g.
> web-servers on their home PCs.  This meant that the entire Internet
> could browse their homepage, but they could not show it to their
> neighbor...
>=20
> This patch solved the issue by doing proxy arp'ing on the router agai=
nst
> the "local" network, thus making it possible for customers to
> communicate, but via the router.  This also gives the ability to do
> firewalling on the router between customers on an Ethernet. (In our
> solution the Linux router also have a personal firewall configurable =
per
> customer.)
>=20

I can see value in that - you're forcing all traffic through the
upstream router for policy enforcement purposes, without having to have
point-to-point (simulated or otherwise) links between customers and the
router, and avoiding IP address waste by not using /30s. You're pretty
much making the ethernet a Non-broadcast Multi-Access link.



> It is simply enabled on an interface via e.g.:
>=20
>  echo 1 > /proc/sys/net/ipv4/conf/eth2.1013/proxy_arp_pvlan
>=20
> Hope that helps your understand the idea and usage :-)
>=20
> --=20
> Med venlig hilsen / Best regards
>   Jesper Brouer
>   ComX Networks A/S
>   Linux Network Kernel Developer
>   Cand. Scient Datalog / MSc.CS
>   Author of http://adsl-optimizer.dk
>   LinkedIn: http://www.linkedin.com/in/brouer
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
