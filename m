From: Leonardo Uzcudun <uzcudunl@yahoo.it>
Subject: Re: VLAN 1 - Native
Date: Wed, 1 Feb 2012 15:14:39 +0000 (GMT)
Message-ID: <1328109279.13003.YahooMailNeo@web29014.mail.ird.yahoo.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>  <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>  <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>  <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com> <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	yao zhao <yao.development@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm10-vm0.bullet.mail.ird.yahoo.com ([77.238.189.90]:26560 "HELO
	nm10-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754835Ab2BAPV1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 10:21:27 -0500
In-Reply-To: <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, all those points are clear. My question is: can i do anything in t=
he linux side (i can't change the switch config) to make the traffic on=
 vlan 1 to function?

Example: how do those linux-wifi-access points that support vlans are a=
ble to have VLAN 1 and other vlans?

Thanks again.

Leo



----- Messaggio originale -----
Da: Eric Dumazet <eric.dumazet@gmail.com>
A: yao zhao <yao.development@gmail.com>
Cc: Leonardo Uzcudun <uzcudunl@yahoo.it>; "netdev@vger.kernel.org" <net=
dev@vger.kernel.org>
Inviato: Mercoled=EC 1 Febbraio 2012 16:05
Oggetto: Re: VLAN 1 - Native

Le mercredi 01 f=E9vrier 2012 =E0 09:57 -0500, yao zhao a =E9crit :
> On Wed, Feb 1, 2012 at 9:50 AM, yao zhao <yao.development@gmail.com> =
wrote:
> >
> >
> > On Wed, Feb 1, 2012 at 8:04 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >>
> >> Le mercredi 01 f=E9vrier 2012 =E0 11:24 +0000, Leonardo Uzcudun a =
=E9crit :
> >> > ________________________________
> >> > Da: Leonardo Uzcudun <uzcudunl@yahoo.it>
> >> > A: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> >> > Inviato: Mercoled=EC 1 Febbraio 2012 12:22
> >> > Oggetto: VLAN 1 - Native
> >> >
> >> > Hello:
> >> >
> >> > I'm connecting my Linux computer (debian 2.6.32-5) to a switch t=
o
> >> > implement vlans.
> >> >
> >> > All is working fine except for the VLAN 1. Of sure you are aware=
 of
> >> > this situation and i would like to knoe if there is any paramete=
r or
> >> > setting that i should set in the vlan (linux side, not switch)
> >> > configuration. Here's my configuration:
> >> > ip addr add 0.0.0.0 dev eth0
> >> > ip link set eth0 up
> >> > ip link add link eth0 name eth0.1 type vlan id 1
> >> > ip link add link eth0 name eth0.101 type vlan id 101
> >> > ip addr add 0.0.0.0 dev eth0.1
> >> > ip addr add 0.0.0.0 dev eth0.101
> >> > ip link set eth0.101 up
> >> > ip link set eth0.1 up
> >> > brctl addbr br_vlan_1
> >> > brctl addbr br_vlan_101
> >> > brctl addif br_vlan_1 eth0.1
> >> > brctl addif br_vlan_101 eth0.101
> >> > ip addr add 0.0.0.0 dev br_vlan_1
> >> > ip
> >> > addr add 0.0.0.0 dev br_vlan_101
> >> > ip link set br_vlan_1 up
> >> > ip link set br_vlan_101 up
> >> >
> >> > Traffic on vlan 101 is working fine. Traffic on VLAN 1 is not wo=
rking
> >> > cause the packets are going out from eth0 like tagged. How could=
 i set
> >> > the VID 1 as untagged?
> >>
> >> What do you mean by "sending packets for VID 1, untagged " ?
> >>
>=A0 on switch like Cisco: vlan 1 is the native vlan or default vlan so=
 it is
>=A0 untagged. untagged means packet has no vlan header.
>=20
> >>
> >> What is the difference between vlan 101 and vlan 1 ?
>=20
>=A0 No other difference. Just because it is vlan 1=A0 which is special=
 in
>=A0 switches(of course it can be changed on switch side but he doesn't=
 want to)

VID=3D1 is not the "known" native vlan at all, this is a vendor (stupid=
 ?)
extension.

There is no ID reserved to untagged traffic in the 802.1Q specs, since
by definition, if traffic is untagged, there is _no_ VLAN tag in the
frame.

Untagged traffic on linux is on eth0 itself (ingress or egress), not on
eth0.xxx
