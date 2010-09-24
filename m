From: Ulrich Weber <uweber@astaro.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Fri, 24 Sep 2010 18:40:06 +0200
Message-ID: <4C9CD466.4010909@astaro.com>
References: <20100922162209.GA10281@babylon>	 <20100922.203442.233700254.davem@davemloft.net>	 <20100923144708.GA8037@babylon> <1285254302.2509.47.camel@edumazet-laptop>	 <4C9CBCFC.6080300@gmail.com> <1285342083.2503.252.camel@edumazet-laptop>	 <4C9CC608.7010401@astaro.com> <1285344352.2503.321.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <ulrich.weber@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-77.dex002.intermedia.net ([64.78.20.107]:56851 "EHLO
	DHOST002-77.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932784Ab0IXQkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 12:40:13 -0400
In-Reply-To: <1285344352.2503.321.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/2010 06:05 PM, Eric Dumazet wrote:
> Le vendredi 24 septembre 2010 =C3=A0 17:38 +0200, Ulrich Weber a =C3=A9=
crit :
>> steps to reproduce:
>> server:
>>  ip route add 1.0.0.0/8 dev dummy0
>>
>> client:
>>  ip route add 1.0.0.0/8 dev eth0
>>  nmap --min-rate 500 -sP 1.0.0.0/8
>>
>=20
> Great, you use nmap and fill 'client' neighbour cache.

Nope, I fills the 'server' neighbor cache too
due cached routes in arp_process():
        if (arp->ar_op =3D=3D htons(ARPOP_REQUEST) &&
            ip_route_input_noref(skb, tip, sip, 0, dev) =3D=3D 0)

> Now, back to the _real_ problem, please ?
>=20
> <quote>
>=20
> Background: At home I have two Internet connections, DSL and Cable.
> DSL is the primary uplink while Cable is the secondary.
> My Cable ISP is flooding me with ARP request from 10.0.0.0/8,
> which creates routes via the primary uplink.
> There are thousands of cached routes and after some time
> I get "Neighbour table overflow" messages.
>=20
> </quote>
>=20
> You receive an ARP request on device eth1,
> this creates a route on eth0 ?
>=20
> Could you send your routing/address setup ?
>=20
> ip addr
> ip ro
>=20

ARP request flood comes in via eth2.

Have to correct myself: With configuration below only route cache
increases but no "Neighbour table overflow".

By adding "ip route add 10.0.0.0/8 dev eth0" the Neighbor table overflo=
w
will occur.


1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    inet 192.168.1.1/24 brd 192.168.1.255 scope global eth0
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    inet 78.43.x.x/22 brd 78.43.35.255 scope global eth2
12: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1492 qdisc hfsc
state UNKNOWN qlen 3
    inet 95.114.x.x peer 213.20.56.129/32 scope global ppp0


default via 213.20.56.129 dev ppp0
78.43.32.0/22 dev eth2  proto kernel  scope link  src 78.43.x.x
127.0.0.0/8 dev lo  scope link
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.1
213.20.56.129 dev ppp0  proto kernel  scope link  src 95.114.x.x


--=20
Ulrich Weber | uweber@astaro.com | Software Engineer
Astaro GmbH & Co. KG | www.astaro.com | Phone +49-721-25516-0 | Fax =E2=
=80=93200
An der RaumFabrik 33a | 76227 Karlsruhe | Germany
