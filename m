From: Leonardo Uzcudun <uzcudunl@yahoo.it>
Subject: Re: VLAN 1 - Native
Date: Wed, 1 Feb 2012 16:44:40 +0000 (GMT)
Message-ID: <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com> <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com> <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com> <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com> <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
Reply-To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: yao zhao <yao.development@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm9-vm0.bullet.mail.ird.yahoo.com ([77.238.189.197]:41863 "HELO
	nm9-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753749Ab2BAQon convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 11:44:43 -0500
In-Reply-To: <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sorry guys but i'm not understanding. Allow me to ask in a differen=
t way.

I've a linux computer with 3 network cards (eth0, eth1 and eth2)

eth0 is connected to a switch with vlans config.
eth1 is connected to a network that has VID 1
eth2 is connected to a network that has VID 101

I've the following configuration:

ip addr add 0.0.0.0 dev eth0
ip link set eth0 up
ip link add link eth0 name eth0.1 type vlan id 1
ip link add link eth0 name eth0.101 type vlan id 101
ip addr add 0.0.0.0 dev eth0.1
ip addr add 0.0.0.0 dev eth0.101
ip link set eth0.101 up
ip link set eth0.1 up
brctl addbr br_vlan_1
brctl addbr br_vlan_101
brctl addif br_vlan_1 eth0.1 eth1
brctl addif br_vlan_101 eth0.101 eth2
ip addr add 0.0.0.0 dev br_vlan_1
ip addr add 0.0.0.0 dev br_vlan_101
ip link set br_vlan_1 up
ip link set br_vlan_101 up


with this setup, the traffic on VID 101 is working fine. The devices ac=
ross the switch and eth2 communicate each other but, the devices on VID=
 1 don't communicate with those connected to eth1

If I remove eth0.1 and add eth0 to br_vlan_1 i have the opposite situat=
ion:
the traffic on VID 101 is NOT working. The devices across the switch an=
d eth2 DO NOT communicate each other
but, the devices on VID 1 communicate with those connected to eth1. Of =
course on br_vlan_1 i'm getting the VID 1 traffic AND the VID 101....

Thanks again,

Leo





----- Messaggio originale -----
Da: yao zhao <yao.development@gmail.com>
A: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Leonardo Uzcudun <uzcudunl@yahoo.it>; "netdev@vger.kernel.org" <net=
dev@vger.kernel.org>
Inviato: Mercoled=EC 1 Febbraio 2012 17:25
Oggetto: Re: VLAN 1 - Native

On Wed, Feb 1, 2012 at 10:05 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 01 f=E9vrier 2012 =E0 09:57 -0500, yao zhao a =E9crit :
>> On Wed, Feb 1, 2012 at 9:50 AM, yao zhao <yao.development@gmail.com>=
 wrote:
>> >
>> >
>> > On Wed, Feb 1, 2012 at 8:04 AM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>> >>
>> >> Le mercredi 01 f=E9vrier 2012 =E0 11:24 +0000, Leonardo Uzcudun a=
 =E9crit :
>> >> > ________________________________
>> >> > Da: Leonardo Uzcudun <uzcudunl@yahoo.it>
>> >> > A: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
>> >> > Inviato: Mercoled=EC 1 Febbraio 2012 12:22
>> >> > Oggetto: VLAN 1 - Native
>> >> >
>> >> > Hello:
>> >> >
>> >> > I'm connecting my Linux computer (debian 2.6.32-5) to a switch =
to
>> >> > implement vlans.
>> >> >
>> >> > All is working fine except for the VLAN 1. Of sure you are awar=
e of
>> >> > this situation and i would like to knoe if there is any paramet=
er or
>> >> > setting that i should set in the vlan (linux side, not switch)
>> >> > configuration. Here's my configuration:
>> >> > ip addr add 0.0.0.0 dev eth0
>> >> > ip link set eth0 up
>> >> > ip link add link eth0 name eth0.1 type vlan id 1
>> >> > ip link add link eth0 name eth0.101 type vlan id 101
>> >> > ip addr add 0.0.0.0 dev eth0.1
>> >> > ip addr add 0.0.0.0 dev eth0.101
>> >> > ip link set eth0.101 up
>> >> > ip link set eth0.1 up
>> >> > brctl addbr br_vlan_1
>> >> > brctl addbr br_vlan_101
>> >> > brctl addif br_vlan_1 eth0.1
>> >> > brctl addif br_vlan_101 eth0.101
>> >> > ip addr add 0.0.0.0 dev br_vlan_1
>> >> > ip
>> >> > addr add 0.0.0.0 dev br_vlan_101
>> >> > ip link set br_vlan_1 up
>> >> > ip link set br_vlan_101 up
>> >> >
>> >> > Traffic on vlan 101 is working fine. Traffic on VLAN 1 is not w=
orking
>> >> > cause the packets are going out from eth0 like tagged. How coul=
d i set
>> >> > the VID 1 as untagged?
>> >>
>> >> What do you mean by "sending packets for VID 1, untagged " ?
>> >>
>> =A0on switch like Cisco: vlan 1 is the native vlan or default vlan s=
o it is
>> =A0untagged. untagged means packet has no vlan header.
>>
>> >>
>> >> What is the difference between vlan 101 and vlan 1 ?
>>
>> =A0No other difference. Just because it is vlan 1 =A0which is specia=
l in
>> =A0switches(of course it can be changed on switch side but he doesn'=
t want to)
>
> VID=3D1 is not the "known" native vlan at all, this is a vendor (stup=
id ?)
> extension.
>
That is true. But in IEEE standard it also said you can specify
whether a vlan can be untagged or tagged on egress.

> There is no ID reserved to untagged traffic in the 802.1Q specs, sinc=
e
> by definition, if traffic is untagged, there is _no_ VLAN tag in the
> frame.
>
> Untagged traffic on linux is on eth0 itself (ingress or egress), not =
on
> eth0.xxx
>
If you want linux to do as a switch too, then you can have to make up
something that what ERic said, use physical interface as the vlan 1,
as it is untagged. When vlan 1 is not native vlan you have to change
back to eth0.1. and change that new native vlan to physical interface.

yao
>
>
>
