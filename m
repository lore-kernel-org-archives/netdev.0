From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix arp requests sends with isolated
 routes
Date: Mon, 17 Feb 2014 14:56:35 -0500 (EST)
Message-ID: <20140217.145635.1123180851794758928.davem@davemloft.net>
References: <52FE3D5B.6060103@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: f.cachereul@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbaBQT4h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:56:37 -0500
In-Reply-To: <52FE3D5B.6060103@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=E7ois Cachereul <f.cachereul@alphalink.fr>
Date: Fri, 14 Feb 2014 16:59:23 +0100

> Make arp_send_all() try to send arp packets through slave devices eve=
nt
> if no route to arp_ip_target is found. This is useful when the route
> is in an isolated routing table with routing rule parameters like oif=
 or
> iif in which case ip_route_output() return an error.
> Thus, the arp packet is send without vlan and with the bond ip addres=
s
> as sender.
>=20
> Signed-off-by: Fran=E7ois CACHEREUL <f.cachereul@alphalink.fr>
> ---
> This previously worked, the problem was added in 2.6.35 with vlan 0
> added by default when the module 8021q is loaded. Before that no rout=
e
> lookup was done if the bond device did not have any vlan. The problem
> now exists event if the module 8021q is not loaded.

I don't like this at all, you're trying to paper over the fact that we
can't set the flow key correctly at this point.

Just assuming the route might be there and trying anyways is not really
acceptable in my opinion.  There's a reason we do a route lookup at all=
=2E
