From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sun, 4 Sep 2011 09:36:34 -0700
Message-ID: <20110904093634.685d7c56@nehalam.ftrdhcpuser.net>
References: <20110902172220.830228928@vyatta.com>
	<20110902172247.396753508@vyatta.com>
	<4E614CF7.7030700@gmail.com>
	<20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
	<4E6272BC.4020707@gmail.com>
	<20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>
	<4E632A2E.5040805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57361 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751320Ab1IDQgW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2011 12:36:22 -0400
In-Reply-To: <4E632A2E.5040805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 04 Sep 2011 09:35:10 +0200
Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:

> Le 04/09/2011 06:14, Stephen Hemminger a =E9crit :
>=20
> >> Instead of asserting carrier when the bridge have no port, can't w=
e assert carrier when the three
> >> following condition are true at the same time :
> >>
> >> - The bridge have no port.
> >> - At least one IP address is setup on the bridge.
> >> - The two above conditions are true for more than a configurable a=
mount of seconds, with a default
> >> of 10, for example.
> >>
> >> This would only delay carrier on for a few seconds for the regress=
ion and keep the current behavior
> >> (carrier off until at least 1 port is on) for DHCP.
> >
> > This fails on two counts:
> > 1. Bridge's often run without IP addresses!
> > 2. DHCP won't try and send out request until carrier is true.
>=20
> Sorry, I missed to say that we should of course also assert carrier o=
n if one port has carrier on.
>=20
> And rethinking about it, the delay is probably useless :
>=20
> bridge_carrier_on =3D at_least_one_port_has_carrier_on | (bridge_has_=
no_port & bridge_has_at_least_one_ip)
>=20
> That way :
> - for those using bridge without any port, manually setting the IP wi=
ll assert carrier on. (By the=20
> way, why don't they use a dummy device instead?)
>=20
> - for those using bridge with ports:
> -- Using any kind of autoconfig will work as expected. Carrier will o=
nly be asserted at the time=20
> first port get carrier.
> -- Using static IP confifiguration, carrier will possibly be erroneou=
sly reported as on during the=20
> small time gap between IP address configuration and first port is add=
ed to the bridge. This time gap=20
> may be removed by simply configuring the IP after the first port is a=
dded. This is probably already=20
> true for most distribs. And anyway, this time gap is probably not a p=
roblem.
> -- Carrier will also be erroneously reported as on after removing the=
 last port, if the bridge still=20
> has an IP. (But we can arrange for this not to happen).
>=20
> And in order to ensure user really understand why carrier is on of of=
f, we can simply issue an INFO=20
> message for the non-natural case (bridge_has_no_port & bridga_has_at_=
least_one_ip).
>=20
> I consider all this reasonable.
>=20
> 	Nicolas.

Any bridge behaviour based on IP address configuration is a
layering violation and won't work.  The problem is related to dynamic i=
ssues
with IPv6 and DHCP and needs to be addressed at that level.
