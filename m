From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Fri, 28 Jan 2011 07:10:21 +0530
Message-ID: <AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com>
References: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com>
	<AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>
	<20110116192017.GA3569@electric-eye.fr.zoreil.com>
	<AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com>
	<AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>
	<20110118012146.GA3704@electric-eye.fr.zoreil.com>
	<AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com>
	<20110127150744.GA7925@electric-eye.fr.zoreil.com>
	<AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com>
	<20110127165031.GA7966@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53307 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863Ab1A1BkX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 20:40:23 -0500
Received: by bwz15 with SMTP id 15so2803184bwz.19
        for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 17:40:21 -0800 (PST)
In-Reply-To: <20110127165031.GA7966@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 10:20 PM, Francois Romieu <romieu@fr.zoreil.com=
> wrote:
> Anand Raj Manickam <anandrm@gmail.com> :
>> On Thu, Jan 27, 2011 at 8:37 PM, Francois Romieu <romieu@fr.zoreil.c=
om> wrote:
>> > Anand Raj Manickam <anandrm@gmail.com> :
> [...]
>> > - ip addr show
>>
>> 3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast ql=
en 1000
>> =A0 =A0 link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>> =A0 =A0 inet 172.16.1.1/16 brd 172.16.255.255 scope global eth0
>> =A0 =A0 inet6 fe80::217:54ff:fe00:f662/64 scope link
>> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>>
>> 8: eth0.50@eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noque=
ue
>> =A0 =A0 link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>> =A0 =A0 inet 172.16.10.10/24 brd 172.16.10.255 scope global eth0.50
>> =A0 =A0 inet6 fe80::217:54ff:fe00:f662/64 scope link
>> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>
> Could you try again after issuing :
>
> ip addr del 172.16.1.1/16 brd 172.16.255.255 dev eth0


I did try this NO luck ;-(



>
> then send the unabbreviated "ip addr show" and "ip route show all" if
> things do not perform better.
>

 ip addr show
1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: sit0: <NOARP> mtu 1480 qdisc noop
    link/sit 0.0.0.0 brd 0.0.0.0
3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen =
1000
    link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::217:54ff:fe00:f662/64 scope link
       valid_lft forever preferred_lft forever
4: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast =
qlen 1000
    link/ether 00:17:54:00:f6:63 brd ff:ff:ff:ff:ff:ff
5: eth2: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen =
1000
    link/ether 00:30:67:09:2c:b9 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.2/24 brd 10.1.1.255 scope global eth2
    inet6 fe80::230:67ff:fe09:2cb9/64 scope link
       valid_lft forever preferred_lft forever
6: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:17:54:00:65:6b brd ff:ff:ff:ff:ff:ff
7: eth4: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen =
1000
    link/ether 00:17:54:00:65:6a brd ff:ff:ff:ff:ff:ff
    inet 192.168.138.155/24 brd 192.168.138.255 scope global eth4
    inet6 fe80::217:54ff:fe00:656a/64 scope link
       valid_lft forever preferred_lft forever
8: eth0.50@eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
    link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
    inet 172.16.10.10/24 brd 172.16.10.255 scope global eth0.50
    inet6 fe80::217:54ff:fe00:f662/64 scope link
       valid_lft forever preferred_lft forever


> (no iptables / ip rules wizardry, right ?)
>
> [...]
>> > - ethtool -k eth0
>>
>> Offload parameters for eth0:
>> rx-checksumming: on
>> tx-checksumming: off
>> scatter-gather: off
>> tcp segmentation offload: off
>> udp fragmentation offload: off
>> generic segmentation offload: off
>
> Ok.
>
> [...]
>> > I do not get the "VLAN tag gets stripped" concept, especially on T=
x.
>> > Does it mean "no packet" or "a packet whose content is wrong" ?
>>
>> Sorry for not being clear ;-)
>>
>> When we transmit a packet with VLAN TAG , the TAG get stripped when
>> transmitted through the device , the other end trunk port / sniffer
>> does NOT see a TAG.
>> Similarly , when a VLAN Tagged packet is sent from the other end , T=
he
>> TAG gets stripped by the device , We DONOT see the tag .
>
> But the data flows in both directions, right ?
>
>> I use tcpdump -i eth0 -n -nn -e vlan 50
>> to see if the packets are gettin tagged or NOT .
>>
>> The same config works on forcedeth
>
> What do you call "same config" ?

The Same setup below works on forcedeth driver
>
> I am mildly convinced that your config is simple enough to isolate a
> driver level vlan problem.

The reason why i m sure its on the Driver / Chipset is this ..

The 8021q module is loaded .
vconfig add eth0 50
ifconfig eth0.50 172.16.1.10 up

ping -I eth0.50 172.16.1.1 .

All packets on Tx & Rx have the VLAN tag stripped on Tx & Rx.

On debugging the Driver , we found that on Tx the VLAN tag is present.

static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *d=
ev)
{
=2E
=2E
tp->tx_skb[entry].len =3D len;
txd->addr =3D cpu_to_le64(mapping);
txd->opts2 =3D cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
printk("The Vlan tag %x \n",txd->opts2);
=2E
=2E
}

The Vlan tag 23200

In the above value 23200
2 - TxVlanTag
32 - Vlan tag (50).

=46rom the above we are clear that the Vlan tag reaches the driver .







>
> --
> Ueimor
>
