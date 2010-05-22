From: "George B." <georgeb@gmail.com>
Subject: Re: VLANs, bonding redux: vlan state does not follow ethernet
Date: Sat, 22 May 2010 10:47:54 -0700
Message-ID: <AANLkTimar_hs5zpvbB6iGUg3b9UqgUASqlhMtK81ccXZ@mail.gmail.com>
References: <AANLkTimxJHKjAEm7wMYObFn9U3Sc1WPRYUuFFIKwwAyD@mail.gmail.com>
	 <AANLkTim9nKSOdTW9YcrfNNJCmZoJ6t40mY_9f60GrWuG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58279 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab0EVRr4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 13:47:56 -0400
Received: by fxm5 with SMTP id 5so1596324fxm.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 10:47:54 -0700 (PDT)
In-Reply-To: <AANLkTim9nKSOdTW9YcrfNNJCmZoJ6t40mY_9f60GrWuG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 21, 2010 at 11:45 PM, George B. <georgeb@gmail.com> wrote:
> On Fri, May 21, 2010 at 11:24 PM, George B. <georgeb@gmail.com> wrote=
:
>> Using 2.6.34 I am trying to remove bottlenecks. =A0Instead of bondin=
g
>> two ethernet interfaces and applying vlans to the bond, I am applyin=
g
>> the vlans to the ethernet and bonding the vlans creating a separate
>> bond interface for each vlan.
>>
>> The trouble now is that the bond interface does not see when the
>> ethernet interface goes down. =A0The vlan reports to the bonding dri=
ver
>> that it is up when the ethernet it is connected to is down. =A0This
>> results in packet loss through the bond interface as the bond driver
>> attempts to use that vlan.
>>
>> eth1 shows having no link:
>>
>> root@sandbox:/proc/net# ethtool eth1
>> Settings for eth1:
>> =A0 =A0 =A0 =A0Supported ports: [ TP ]
>> =A0 =A0 =A0 =A0Supported link modes: =A0 10baseT/Half 10baseT/Full
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0100ba=
seT/Half 100baseT/Full
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01000b=
aseT/Full
>> =A0 =A0 =A0 =A0Supports auto-negotiation: Yes
>> =A0 =A0 =A0 =A0Advertised link modes: =A010baseT/Half 10baseT/Full
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0100ba=
seT/Half 100baseT/Full
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01000b=
aseT/Full
>> =A0 =A0 =A0 =A0Advertised pause frame use: No
>> =A0 =A0 =A0 =A0Advertised auto-negotiation: Yes
>> =A0 =A0 =A0 =A0Link partner advertised link modes: =A0Not reported
>> =A0 =A0 =A0 =A0Link partner advertised pause frame use: No
>> =A0 =A0 =A0 =A0Link partner advertised auto-negotiation: No
>> =A0 =A0 =A0 =A0Speed: Unknown!
>> =A0 =A0 =A0 =A0Duplex: Unknown! (255)
>> =A0 =A0 =A0 =A0Port: Twisted Pair
>> =A0 =A0 =A0 =A0PHYAD: 1
>> =A0 =A0 =A0 =A0Transceiver: internal
>> =A0 =A0 =A0 =A0Auto-negotiation: on
>> =A0 =A0 =A0 =A0MDI-X: Unknown
>> =A0 =A0 =A0 =A0Supports Wake-on: pumbag
>> =A0 =A0 =A0 =A0Wake-on: g
>> =A0 =A0 =A0 =A0Current message level: 0x00000001 (1)
>> =A0 =A0 =A0 =A0Link detected: no
>>
>> bonding driver says eth1.99 reports MII status up:
>>
>> root@sandbox:/proc/net# cat bonding/bond0
>> Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
>>
>> Bonding Mode: load balancing (round-robin)
>> MII Status: up
>> MII Polling Interval (ms): 0
>> Up Delay (ms): 0
>> Down Delay (ms): 0
>>
>> Slave Interface: eth0.99
>> MII Status: up
>> Link Failure Count: 0
>> Permanent HW addr: 00:26:9e:1c:d3:3e
>>
>> Slave Interface: eth1.99
>> MII Status: up
>> Link Failure Count: 0
>> Permanent HW addr: 00:26:9e:1c:d3:3f
>>
>> is there some parameter I can give that tells the vlan driver to
>> follow the state of the interface it is attached to? =A0Having a vla=
n
>> that reports being up all the time even when its underlying interfac=
e
>> is down is less than useful. It would seem intuitive that a vlan's
>> state would follow that of the interface it is attached to.
>>
>> root@sandbox:/proc/net# cat vlan/eth0.99
>> eth0.99 =A0VID: 99 =A0 =A0 =A0 =A0 REORDER_HDR: 1 =A0dev->priv_flags=
: 21
>> =A0 =A0 =A0 =A0 total frames received =A0 =A0 =A0 =A0 =A0 32
>> =A0 =A0 =A0 =A0 =A0total bytes received =A0 =A0 =A0 =A0 4735
>> =A0 =A0 =A0Broadcast/Multicast Rcvd =A0 =A0 =A0 =A0 =A0 =A00
>>
>> =A0 =A0 =A0total frames transmitted =A0 =A0 =A0 =A0 =A0 50
>> =A0 =A0 =A0 total bytes transmitted =A0 =A0 =A0 =A0 3852
>> =A0 =A0 =A0 =A0 =A0 =A0total headroom inc =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0 =A0 =A0 =A0 total encap on xmit =A0 =A0 =A0 =A0 =A0 =A00
>> Device: eth0
>> INGRESS priority mappings: 0:0 =A01:0 =A02:0 =A03:0 =A04:0 =A05:0 =A0=
6:0 7:0
>> =A0EGRESS priority mappings:
>> root@sandbox:/proc/net# cat vlan/eth1.99
>> eth1.99 =A0VID: 99 =A0 =A0 =A0 =A0 REORDER_HDR: 1 =A0dev->priv_flags=
: 21
>> =A0 =A0 =A0 =A0 total frames received =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0 =A0 =A0 =A0total bytes received =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0 =A0Broadcast/Multicast Rcvd =A0 =A0 =A0 =A0 =A0 =A00
>>
>> =A0 =A0 =A0total frames transmitted =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0 =A0 total bytes transmitted =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0 =A0 =A0 =A0 =A0total headroom inc =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0 =A0 =A0 =A0 total encap on xmit =A0 =A0 =A0 =A0 =A0 =A00
>> Device: eth1
>> INGRESS priority mappings: 0:0 =A01:0 =A02:0 =A03:0 =A04:0 =A05:0 =A0=
6:0 7:0
>> =A0EGRESS priority mappings:
>>
>> root@sandbox:/proc/net# ping 10.1.99.1
>> PING 10.1.99.1 (10.1.99.1) 56(84) bytes of data.
>> 64 bytes from 10.1.99.1: icmp_seq=3D2 ttl=3D255 time=3D0.299 ms
>> 64 bytes from 10.1.99.1: icmp_seq=3D4 ttl=3D255 time=3D0.311 ms
>> 64 bytes from 10.1.99.1: icmp_seq=3D6 ttl=3D255 time=3D0.325 ms
>> 64 bytes from 10.1.99.1: icmp_seq=3D8 ttl=3D255 time=3D0.291 ms
>> 64 bytes from 10.1.99.1: icmp_seq=3D10 ttl=3D255 time=3D0.308 ms
>>
>> George
>>
>
> But interestingly, mii-tool reports the correct result:
>
> root@sandbox:/usr/src/linux-source-2.6.34/Documentation/networking#
> mii-tool -v eth1.99
>
> eth1.99: no link
> =A0product info: vendor 00:50:43, model 10 rev 0
> =A0basic mode: =A0 autonegotiation enabled
> =A0basic status: no link
> =A0capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10=
baseT-HD
> =A0advertising: =A0100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD fl=
ow-control
>

I can't use arp monitor because when I do that it just flips back and
forth each second between slaves each monitor period:

May 22 10:45:28 sandbox kernel: [69276.450013] bonding: bond0: making
interface eth0.99 the new active one.
May 22 10:45:29 sandbox kernel: [69277.450010] bonding: bond0: link
status definitely up for interface eth1.99.
May 22 10:45:30 sandbox kernel: [69278.450009] bonding: bond0: link
status definitely down for interface eth0.99, disabl
ing it
May 22 10:45:30 sandbox kernel: [69278.450012] bonding: bond0: making
interface eth1.99 the new active one.
May 22 10:45:31 sandbox kernel: [69279.450009] bonding: bond0: link
status definitely up for interface eth0.99.
May 22 10:45:32 sandbox kernel: [69280.450009] bonding: bond0: link
status definitely down for interface eth1.99, disabl
ing it
May 22 10:45:32 sandbox kernel: [69280.450012] bonding: bond0: making
interface eth0.99 the new active one.
May 22 10:45:33 sandbox kernel: [69281.450012] bonding: bond0: link
status definitely up for interface eth1.99.
May 22 10:45:34 sandbox kernel: [69282.450009] bonding: bond0: link
status definitely down for interface eth0.99, disabl
ing it
May 22 10:45:34 sandbox kernel: [69282.450012] bonding: bond0: making
interface eth1.99 the new active one.
May 22 10:45:35 sandbox kernel: [69283.450012] bonding: bond0: link
status definitely up for interface eth0.99.
May 22 10:45:36 sandbox kernel: [69284.450009] bonding: bond0: link
status definitely down for interface eth1.99, disabl
ing it
May 22 10:45:36 sandbox kernel: [69284.450012] bonding: bond0: making
interface eth0.99 the new active one.
May 22 10:45:37 sandbox kernel: [69285.450012] bonding: bond0: link
status definitely up for interface eth1.99.
May 22 10:45:38 sandbox kernel: [69286.450008] bonding: bond0: link
status definitely down for interface eth0.99, disabl
ing it
May 22 10:45:38 sandbox kernel: [69286.450011] bonding: bond0: making
interface eth1.99 the new active one.
May 22 10:45:39 sandbox kernel: [69287.450010] bonding: bond0: link
status definitely up for interface eth0.99.
May 22 10:45:40 sandbox kernel: [69288.450008] bonding: bond0: link
status definitely down for interface eth1.99, disabl
ing it

This is with both physical links up.  The arp monitor just causes the
links to constantly fail back and forth each arp_monitor interval.
