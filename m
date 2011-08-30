From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 802.1Q VLAN random tag injected when vlan configured on
 forcedeth interface
Date: Tue, 30 Aug 2011 15:23:48 +0200
Message-ID: <1314710628.2935.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110830125111.GA28341@ruff.mobi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Ruslan N. Marchenko" <me@ruff.mobi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56416 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab1H3NXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 09:23:46 -0400
Received: by wwf5 with SMTP id 5so6802648wwf.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 06:23:45 -0700 (PDT)
In-Reply-To: <20110830125111.GA28341@ruff.mobi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 14:51 +0200, Ruslan N. Marchenko a =C3=
=A9crit :
> Hi guys,
> I've faced with strange behaviour of 8021q driver: when enabling vlan=
 subinterface on eth interface I'm getting ~50% packetloss due to packe=
ts are marked with incorrect tags (and eventually dropped by kernel sin=
ce no vlans configured for such IDs).
> Scenario:
> [    0.476950] cpufreq-nforce2: No nForce2 chipset.
> [    1.519133] forcedeth: Reverse Engineered nForce ethernet driver. =
Version 0.64.
> [    1.519991] forcedeth 0000:00:0a.0: PCI INT A -> Link[LMAC] -> GSI=
 22 (level, low) -> IRQ 22
> [    1.520037] forcedeth 0000:00:0a.0: setting latency timer to 64
> [    1.586526] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x732 @ 3=
, addr 00:26:18:40:21:61
> [    1.586542] forcedeth 0000:00:0a.0: highdma csum pwrctl gbit lnkti=
m msi desc-v3
>=20
> modprobe 8021q
>=20
> - network still works properly, packets are comming not marked at all=
=2E
>=20
> ip li add link eth0 name vl6 type vlan id 6
>=20
> - from this moment massive packetdrop starting to happen, almost half=
 of the *incoming* packets are shown in tcpdump as=20
> 14:15:52.859296 00:13:f7:1e:fe:e4 > 00:26:18:40:21:61, ethertype 802.=
1Q (0x8100), length 102: vlan 64, p 3, ethertype IPv4, [|ip]
> 14:15:56.869572 00:13:f7:1e:fe:e4 > 00:26:18:40:21:61, ethertype 802.=
1Q (0x8100), length 102: vlan 2112, p 7, ethertype IPv4, [|ip]
>=20
> mostly only these two tags appears (64 & 2112). Moreover this happens=
 as on native vlan level (pure ethernet) so on tagged subinterface (as =
if qinq double tagging) for properly tagged with ID 6 incomming packets=
=2E
>=20
> I've tried disabling all offloads:
>=20
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: off
> scatter-gather: off
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: off
> large-receive-offload: off
> rx-vlan-offload: off
> tx-vlan-offload: off
> ntuple-filters: off
> receive-hashing: off
>=20
> - doesn't have any effect.
> Once executing=20
> ip li del vl6 type vlan
> misterious tags disappear and everything works smoothly. Don't know w=
ho injects that garbage into frames - 8021q or forcedeth driver :(
> Any ideas or suggestions to narrow the problem down?
>=20
> Additional data.
> Link level data dump example for broken frame:
> 12:35:32.175523 00:13:f7:1e:fe:e4 > 00:26:18:40:21:61, ethertype 802.=
1Q (0x8100), length 102: vlan 2112, p 2, ethertype IPv4, [|ip]
>         0x0000:  0026 1840 2161 0013 f71e fee4 8100 4840
>         0x0010:  0800 4500 0054 7a12 0000 4001 eb0f
> 0x0C-0D - TPID: ethertype 802.1Q (0x8100)=20
> 0x0E-0F - TCI (0100100001000000) PCP 010, CFI 0, VID 100001000000/0x8=
40/2112
> 0x10-11 - ethertype IPv4
> normal ping reply follows, which appears untagged in 50% cases with v=
lan configured and 100% cases without.
>=20
> Interface is plugged into openwrt box into non-switched (wan) gigabit=
 port with vid 6 subinterface configured.
>=20

What kernel version are you using ?
