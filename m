From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: ixgbe question
Date: Tue, 24 Nov 2009 11:46:46 +0300
Message-ID: <4B0B9D76.8090009@bigtelecom.ru>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com> <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com> <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com> <Pine.LNX.4.64.0911231500060.24347@ask.diku.dk> <4B0A9E4E.9010804@gmail.com> <19210.54486.353397.804028@gargle.gargle.HOWL> <4B0ABF6D.9000103@gmail.com> <Pine.WNT.4.64.0911231525180.10056@ppwaskie-MOBL2.amr.corp.intel.com> <4B0B8F52.3010005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:45824 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932244AbZKXIqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 03:46:44 -0500
In-Reply-To: <4B0B8F52.3010005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Waskiewicz Jr, Peter P a =C3=A9crit :
>> Ok, I was confused earlier.  I thought you were saying that all pack=
ets=20
>> were headed into a single Rx queue.  This is different.
>>
>> Do you know what version of irqbalance you're running, or if it's ru=
nning=20
>> at all?  We've seen issues with irqbalance where it won't recognize =
the=20
>> ethernet device if the driver has been reloaded.  In that case, it w=
on't=20
>> balance the interrupts at all.  If the default affinity was set to o=
ne=20
>> CPU, then well, you're screwed.
>>
>> My suggestion in this case is after you reload ixgbe and start your =
tests,=20
>> see if it all goes to one CPU.  If it does, then restart irqbalance=20
>> (service irqbalance restart - or just kill it and restart by hand). =
 Then=20
>> start running your test, and in 10 seconds you should see the interr=
upts=20
>> move and spread out.
>>
>> Let me know if this helps,
>=20
> Sure it helps !
>=20
> I tried without irqbalance and with irqbalance (Ubuntu 9.10 ships irq=
balance 0.55-4)
> I can see irqbalance setting smp_affinities to 5555 or AAAA with no d=
irect effect.
>=20
> I do receive 16 different irqs, but all serviced on one cpu.
>=20
> Only way to have irqs on different cpus is to manualy force irq affin=
ities to be exclusive
> (one bit set in the mask, not several ones), and that is not optimal =
for moderate loads.
>=20
> echo 1 >`echo /proc/irq/*/fiber1-TxRx-0/../smp_affinity`
> echo 1 >`echo /proc/irq/*/fiber1-TxRx-1/../smp_affinity`
> echo 4 >`echo /proc/irq/*/fiber1-TxRx-2/../smp_affinity`
> echo 4 >`echo /proc/irq/*/fiber1-TxRx-3/../smp_affinity`
> echo 10 >`echo /proc/irq/*/fiber1-TxRx-4/../smp_affinity`
> echo 10 >`echo /proc/irq/*/fiber1-TxRx-5/../smp_affinity`
> echo 40 >`echo /proc/irq/*/fiber1-TxRx-6/../smp_affinity`
> echo 40 >`echo /proc/irq/*/fiber1-TxRx-7/../smp_affinity`
> echo 100 >`echo /proc/irq/*/fiber1-TxRx-8/../smp_affinity`
> echo 100 >`echo /proc/irq/*/fiber1-TxRx-9/../smp_affinity`
> echo 400 >`echo /proc/irq/*/fiber1-TxRx-10/../smp_affinity`
> echo 400 >`echo /proc/irq/*/fiber1-TxRx-11/../smp_affinity`
> echo 1000 >`echo /proc/irq/*/fiber1-TxRx-12/../smp_affinity`
> echo 1000 >`echo /proc/irq/*/fiber1-TxRx-13/../smp_affinity`
> echo 4000 >`echo /proc/irq/*/fiber1-TxRx-14/../smp_affinity`
> echo 4000 >`echo /proc/irq/*/fiber1-TxRx-15/../smp_affinity`
>=20
>=20
> One other problem is that after reload of ixgbe driver, link is 95% o=
f the time
> at 1 Gbps speed, and I could not find an easy way to force it being 1=
0 Gbps
>=20
> I run following script many times and stop it when 10 Gbps speed if r=
eached.
>=20
> ethtool -A fiber0 rx off tx off
> ip link set fiber0 down
> ip link set fiber1 down
> sleep 2
> ethtool fiber0
> ethtool -s fiber0 speed 10000
> ethtool -s fiber1 speed 10000
> ethtool -r fiber0 &
> ethtool -r fiber1 &
> ethtool fiber0
> ip link set fiber1 up &
> ip link set fiber0 up &
> ethtool fiber0
>=20
> [   33.625689] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver =
- version 2.0.44-k2
> [   33.625692] ixgbe: Copyright (c) 1999-2009 Intel Corporation.
> [   33.625741] ixgbe 0000:07:00.0: PCI INT A -> GSI 32 (level, low) -=
> IRQ 32
> [   33.625760] ixgbe 0000:07:00.0: setting latency timer to 64
> [   33.735579] ixgbe 0000:07:00.0: irq 100 for MSI/MSI-X
> [   33.735583] ixgbe 0000:07:00.0: irq 101 for MSI/MSI-X
> [   33.735585] ixgbe 0000:07:00.0: irq 102 for MSI/MSI-X
> [   33.735587] ixgbe 0000:07:00.0: irq 103 for MSI/MSI-X
> [   33.735589] ixgbe 0000:07:00.0: irq 104 for MSI/MSI-X
> [   33.735591] ixgbe 0000:07:00.0: irq 105 for MSI/MSI-X
> [   33.735593] ixgbe 0000:07:00.0: irq 106 for MSI/MSI-X
> [   33.735595] ixgbe 0000:07:00.0: irq 107 for MSI/MSI-X
> [   33.735597] ixgbe 0000:07:00.0: irq 108 for MSI/MSI-X
> [   33.735599] ixgbe 0000:07:00.0: irq 109 for MSI/MSI-X
> [   33.735602] ixgbe 0000:07:00.0: irq 110 for MSI/MSI-X
> [   33.735604] ixgbe 0000:07:00.0: irq 111 for MSI/MSI-X
> [   33.735606] ixgbe 0000:07:00.0: irq 112 for MSI/MSI-X
> [   33.735608] ixgbe 0000:07:00.0: irq 113 for MSI/MSI-X
> [   33.735610] ixgbe 0000:07:00.0: irq 114 for MSI/MSI-X
> [   33.735612] ixgbe 0000:07:00.0: irq 115 for MSI/MSI-X
> [   33.735614] ixgbe 0000:07:00.0: irq 116 for MSI/MSI-X
> [   33.735633] ixgbe: 0000:07:00.0: ixgbe_init_interrupt_scheme: Mult=
iqueue Enabled: Rx Queue count =3D 16, Tx Queue count =3D 16
> [   33.735638] ixgbe 0000:07:00.0: (PCI Express:5.0Gb/s:Width x8) 00:=
1b:21:4a:fe:54
> [   33.735722] ixgbe 0000:07:00.0: MAC: 2, PHY: 11, SFP+: 5, PBA No: =
e66562-003
> [   33.738111] ixgbe 0000:07:00.0: Intel(R) 10 Gigabit Network Connec=
tion
> [   33.738135] ixgbe 0000:07:00.1: PCI INT B -> GSI 42 (level, low) -=
> IRQ 42
> [   33.738151] ixgbe 0000:07:00.1: setting latency timer to 64
> [   33.853526] ixgbe 0000:07:00.1: irq 117 for MSI/MSI-X
> [   33.853529] ixgbe 0000:07:00.1: irq 118 for MSI/MSI-X
> [   33.853532] ixgbe 0000:07:00.1: irq 119 for MSI/MSI-X
> [   33.853534] ixgbe 0000:07:00.1: irq 120 for MSI/MSI-X
> [   33.853536] ixgbe 0000:07:00.1: irq 121 for MSI/MSI-X
> [   33.853538] ixgbe 0000:07:00.1: irq 122 for MSI/MSI-X
> [   33.853540] ixgbe 0000:07:00.1: irq 123 for MSI/MSI-X
> [   33.853542] ixgbe 0000:07:00.1: irq 124 for MSI/MSI-X
> [   33.853544] ixgbe 0000:07:00.1: irq 125 for MSI/MSI-X
> [   33.853546] ixgbe 0000:07:00.1: irq 126 for MSI/MSI-X
> [   33.853548] ixgbe 0000:07:00.1: irq 127 for MSI/MSI-X
> [   33.853550] ixgbe 0000:07:00.1: irq 128 for MSI/MSI-X
> [   33.853552] ixgbe 0000:07:00.1: irq 129 for MSI/MSI-X
> [   33.853554] ixgbe 0000:07:00.1: irq 130 for MSI/MSI-X
> [   33.853556] ixgbe 0000:07:00.1: irq 131 for MSI/MSI-X
> [   33.853558] ixgbe 0000:07:00.1: irq 132 for MSI/MSI-X
> [   33.853560] ixgbe 0000:07:00.1: irq 133 for MSI/MSI-X
> [   33.853580] ixgbe: 0000:07:00.1: ixgbe_init_interrupt_scheme: Mult=
iqueue Enabled: Rx Queue count =3D 16, Tx Queue count =3D 16
> [   33.853585] ixgbe 0000:07:00.1: (PCI Express:5.0Gb/s:Width x8) 00:=
1b:21:4a:fe:55
> [   33.853669] ixgbe 0000:07:00.1: MAC: 2, PHY: 11, SFP+: 5, PBA No: =
e66562-003
> [   33.855956] ixgbe 0000:07:00.1: Intel(R) 10 Gigabit Network Connec=
tion
>=20
> [   85.208233] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: RX/=
TX
> [   85.237453] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: RX/=
TX
> [   96.080713] ixgbe: fiber1 NIC Link is Down
> [  102.094610] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  102.119572] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  142.524691] ixgbe: fiber1 NIC Link is Down
> [  148.421332] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  148.449465] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  160.728643] ixgbe: fiber1 NIC Link is Down
> [  172.832301] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  173.659038] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  184.554501] ixgbe: fiber0 NIC Link is Down
> [  185.376273] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  186.493598] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  190.564383] ixgbe: fiber0 NIC Link is Down
> [  191.391149] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  192.484492] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  192.545424] ixgbe: fiber1 NIC Link is Down
> [  205.858197] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  206.684940] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  211.991875] ixgbe: fiber1 NIC Link is Down
> [  220.833478] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  220.833630] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  229.804853] ixgbe: fiber1 NIC Link is Down
> [  248.395672] ixgbe: fiber0 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  249.222408] ixgbe: fiber1 NIC Link is Up 1 Gbps, Flow Control: Non=
e
> [  484.631598] ixgbe: fiber1 NIC Link is Down
> [  490.138931] ixgbe: fiber1 NIC Link is Up 10 Gbps, Flow Control: No=
ne
> [  490.167880] ixgbe: fiber0 NIC Link is Up 10 Gbps, Flow Control: No=
ne
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

May be its Flow Director?
Multuqueue in this network card work only if you set 1 queue to 1 cpu c=
ore in smp_affinity :(
In README:


Intel(R) Ethernet Flow Director
-------------------------------
Supports advanced filters that direct receive packets by their flows to
different queues. Enables tight control on routing a flow in the platfo=
rm.
Matches flows and CPU cores for flow affinity. Supports multiple parame=
ters
for flexible flow classification and load balancing.

=46low director is enabled only if the kernel is multiple TX queue capa=
ble.

An included script (set_irq_affinity.sh) automates setting the IRQ to C=
PU
affinity.

You can verify that the driver is using Flow Director by looking at the=
 counter
in ethtool: fdir_miss and fdir_match.

The following three parameters impact Flow Director.


=46dirMode
--------
Valid Range: 0-2 (0=3Doff, 1=3DATR, 2=3DPerfect filter mode)
Default Value: 1

  Flow Director filtering modes.


=46dirPballoc
-----------
Valid Range: 0-2 (0=3D64k, 1=3D128k, 2=3D256k)
Default Value: 0

  Flow Director allocated packet buffer size.


AtrSampleRate
--------------
Valid Range: 1-100
Default Value: 20

  Software ATR Tx packet sample rate. For example, when set to 20, ever=
y 20th
  packet, looks to see if the packet will create a new flow.





