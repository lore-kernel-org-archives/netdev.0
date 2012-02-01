From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 01 Feb 2012 16:05:23 +0100
Message-ID: <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	 <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	 <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	 <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Leonardo Uzcudun <uzcudunl@yahoo.it>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: yao zhao <yao.development@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50807 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369Ab2BAPF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 10:05:27 -0500
Received: by wgbdt10 with SMTP id dt10so1400752wgb.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 07:05:26 -0800 (PST)
In-Reply-To: <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 09:57 -0500, yao zhao a =C3=A9c=
rit :
> On Wed, Feb 1, 2012 at 9:50 AM, yao zhao <yao.development@gmail.com> =
wrote:
> >
> >
> > On Wed, Feb 1, 2012 at 8:04 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >>
> >> Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 11:24 +0000, Leonardo Uzcu=
dun a =C3=A9crit :
> >> > ________________________________
> >> > Da: Leonardo Uzcudun <uzcudunl@yahoo.it>
> >> > A: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> >> > Inviato: Mercoled=C3=AC 1 Febbraio 2012 12:22
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
>  on switch like Cisco: vlan 1 is the native vlan or default vlan so i=
t is
>  untagged. untagged means packet has no vlan header.
>=20
> >>
> >> What is the difference between vlan 101 and vlan 1 ?
>=20
>  No other difference. Just because it is vlan 1  which is special in
>  switches(of course it can be changed on switch side but he doesn't w=
ant to)

VID=3D1 is not the "known" native vlan at all, this is a vendor (stupid=
 ?)
extension.

There is no ID reserved to untagged traffic in the 802.1Q specs, since
by definition, if traffic is untagged, there is _no_ VLAN tag in the
frame.

Untagged traffic on linux is on eth0 itself (ingress or egress), not on
eth0.xxx
