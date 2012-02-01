From: yao zhao <yao.development@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 1 Feb 2012 12:25:00 -0500
Message-ID: <CADDf=MRuAWRFWMiCOOkWBzhW7_B3wRoMEpmk8ij=SxD2QvP3mw@mail.gmail.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	<1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	<1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	<CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	<1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
	<1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:59135 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754906Ab2BARZB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 12:25:01 -0500
Received: by obcva7 with SMTP id va7so1551318obc.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 09:25:00 -0800 (PST)
In-Reply-To: <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How about this?

brctl addif br_vlan_1 eth0 eth1
brctl addif br_vlan_101 eth0.101 eth2.101

yao
On Wed, Feb 1, 2012 at 11:44 AM, Leonardo Uzcudun <uzcudunl@yahoo.it> w=
rote:
> I'm sorry guys but i'm not understanding. Allow me to ask in a differ=
ent way.
>
> I've a linux computer with 3 network cards (eth0, eth1 and eth2)
>
> eth0 is connected to a switch with vlans config.
> eth1 is connected to a network that has VID 1
> eth2 is connected to a network that has VID 101
>
> I've the following configuration:
>
> ip addr add 0.0.0.0 dev eth0
> ip link set eth0 up
> ip link add link eth0 name eth0.1 type vlan id 1
> ip link add link eth0 name eth0.101 type vlan id 101
> ip addr add 0.0.0.0 dev eth0.1
> ip addr add 0.0.0.0 dev eth0.101
> ip link set eth0.101 up
> ip link set eth0.1 up
> brctl addbr br_vlan_1
> brctl addbr br_vlan_101
> brctl addif br_vlan_1 eth0.1 eth1
> brctl addif br_vlan_101 eth0.101 eth2
> ip addr add 0.0.0.0 dev br_vlan_1
> ip addr add 0.0.0.0 dev br_vlan_101
> ip link set br_vlan_1 up
> ip link set br_vlan_101 up
>
>
> with this setup, the traffic on VID 101 is working fine. The devices =
across the switch and eth2 communicate each other but, the devices on V=
ID 1 don't communicate with those connected to eth1
>
> If I remove eth0.1 and add eth0 to br_vlan_1 i have the opposite situ=
ation:
> the traffic on VID 101 is NOT working. The devices across the switch =
and eth2 DO NOT communicate each other
> but, the devices on VID 1 communicate with those connected to eth1. O=
f course on br_vlan_1 i'm getting the VID 1 traffic AND the VID 101....
>
> Thanks again,
>
> Leo
>
>
>
>
>
> ----- Messaggio originale -----
> Da: yao zhao <yao.development@gmail.com>
> A: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Leonardo Uzcudun <uzcudunl@yahoo.it>; "netdev@vger.kernel.org" <n=
etdev@vger.kernel.org>
> Inviato: Mercoled=EC 1 Febbraio 2012 17:25
> Oggetto: Re: VLAN 1 - Native
>
> On Wed, Feb 1, 2012 at 10:05 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le mercredi 01 f=E9vrier 2012 =E0 09:57 -0500, yao zhao a =E9crit :
>>> On Wed, Feb 1, 2012 at 9:50 AM, yao zhao <yao.development@gmail.com=
> wrote:
>>> >
>>> >
>>> > On Wed, Feb 1, 2012 at 8:04 AM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
>>> >>
>>> >> Le mercredi 01 f=E9vrier 2012 =E0 11:24 +0000, Leonardo Uzcudun =
a =E9crit :
>>> >> > ________________________________
>>> >> > Da: Leonardo Uzcudun <uzcudunl@yahoo.it>
>>> >> > A: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
>>> >> > Inviato: Mercoled=EC 1 Febbraio 2012 12:22
>>> >> > Oggetto: VLAN 1 - Native
>>> >> >
>>> >> > Hello:
>>> >> >
>>> >> > I'm connecting my Linux computer (debian 2.6.32-5) to a switch=
 to
>>> >> > implement vlans.
>>> >> >
>>> >> > All is working fine except for the VLAN 1. Of sure you are awa=
re of
>>> >> > this situation and i would like to knoe if there is any parame=
ter or
>>> >> > setting that i should set in the vlan (linux side, not switch)
>>> >> > configuration. Here's my configuration:
>>> >> > ip addr add 0.0.0.0 dev eth0
>>> >> > ip link set eth0 up
>>> >> > ip link add link eth0 name eth0.1 type vlan id 1
>>> >> > ip link add link eth0 name eth0.101 type vlan id 101
>>> >> > ip addr add 0.0.0.0 dev eth0.1
>>> >> > ip addr add 0.0.0.0 dev eth0.101
>>> >> > ip link set eth0.101 up
>>> >> > ip link set eth0.1 up
>>> >> > brctl addbr br_vlan_1
>>> >> > brctl addbr br_vlan_101
>>> >> > brctl addif br_vlan_1 eth0.1
>>> >> > brctl addif br_vlan_101 eth0.101
>>> >> > ip addr add 0.0.0.0 dev br_vlan_1
>>> >> > ip
>>> >> > addr add 0.0.0.0 dev br_vlan_101
>>> >> > ip link set br_vlan_1 up
>>> >> > ip link set br_vlan_101 up
>>> >> >
>>> >> > Traffic on vlan 101 is working fine. Traffic on VLAN 1 is not =
working
>>> >> > cause the packets are going out from eth0 like tagged. How cou=
ld i set
>>> >> > the VID 1 as untagged?
>>> >>
>>> >> What do you mean by "sending packets for VID 1, untagged " ?
>>> >>
>>> =A0on switch like Cisco: vlan 1 is the native vlan or default vlan =
so it is
>>> =A0untagged. untagged means packet has no vlan header.
>>>
>>> >>
>>> >> What is the difference between vlan 101 and vlan 1 ?
>>>
>>> =A0No other difference. Just because it is vlan 1 =A0which is speci=
al in
>>> =A0switches(of course it can be changed on switch side but he doesn=
't want to)
>>
>> VID=3D1 is not the "known" native vlan at all, this is a vendor (stu=
pid ?)
>> extension.
>>
> That is true. But in IEEE standard it also said you can specify
> whether a vlan can be untagged or tagged on egress.
>
>> There is no ID reserved to untagged traffic in the 802.1Q specs, sin=
ce
>> by definition, if traffic is untagged, there is _no_ VLAN tag in the
>> frame.
>>
>> Untagged traffic on linux is on eth0 itself (ingress or egress), not=
 on
>> eth0.xxx
>>
> If you want linux to do as a switch too, then you can have to make up
> something that what ERic said, use physical interface as the vlan 1,
> as it is untagged. When vlan 1 is not native vlan you have to change
> back to eth0.1. and change that new native vlan to physical interface=
=2E
>
> yao
>>
>>
>>
>
