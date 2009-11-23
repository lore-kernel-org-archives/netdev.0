From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 11:37:20 +0100
Message-ID: <4B0A65E0.7060403@gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>  <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com> <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com> <Pine.WNT.4.64.0911230225140.6352@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36670 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756886AbZKWKhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 05:37:18 -0500
In-Reply-To: <Pine.WNT.4.64.0911230225140.6352@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P a =E9crit :
> On Mon, 23 Nov 2009, Eric Dumazet wrote:
>=20
>> Hi Peter
>>
>> I tried a pktgen stress on 82599EB card and could not split RX load =
on multiple cpus.
>>
>> Setup is :
>>
>> One 82599 card with fiber0 looped to fiber1, 10Gb link mode.
>> machine is a HPDL380 G6 with dual quadcore E5530 @2.4GHz (16 logical=
 cpus)
>=20
> Can you specify kernel version and driver version?


Well, I forgot to mention I am only working with net-next-2.6 tree.

Ubuntu 9.10 kernel (Fedora Core 12 installer was not able to recognize =
disks on this machine :( )

ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 2.0.44-=
k2


>=20
>> I use one pktgen thread sending to fiber0 one many dst IP, and check=
ed that fiber1
>> was using many RX queues :
>>
>> grep fiber1 /proc/interrupts=20
>> 117:       1301      13060          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-0
>> 118:        601       1402          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-1
>> 119:        634        832          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-2
>> 120:        601       1303          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-3
>> 121:        620       1246          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-4
>> 122:       1287      13088          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-5
>> 123:        606       1354          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-6
>> 124:        653        827          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-7
>> 125:        639        825          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-8
>> 126:        596       1199          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-9
>> 127:       2013      24800          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-10
>> 128:        648       1353          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-11
>> 129:        601       1123          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-12
>> 130:        625        834          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-13
>> 131:        665       1409          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-14
>> 132:       2637      31699          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1-Tx=
Rx-15
>> 133:          1          0          0          0          0         =
 0          0          0          0          0          0          0   =
       0          0          0          0   PCI-MSI-edge      fiber1:ls=
c
>>
>>
>>
>> But only one CPU (CPU1) had a softirq running, 100%, and many frames=
 were dropped
>>
>> root@demodl380g6:/usr/src# ifconfig fiber0
>> fiber0    Link encap:Ethernet  HWaddr 00:1b:21:4a:fe:54 =20
>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>           Packets re=E7us:4 erreurs:0 :0 overruns:0 frame:0
>>           TX packets:309291576 errors:0 dropped:0 overruns:0 carrier=
:0
>>           collisions:0 lg file transmission:1000=20
>>           Octets re=E7us:1368 (1.3 KB) Octets transmis:18557495682 (=
18.5 GB)
>>
>> root@demodl380g6:/usr/src# ifconfig fiber1
>> fiber1    Link encap:Ethernet  HWaddr 00:1b:21:4a:fe:55 =20
>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>           Packets re=E7us:55122164 erreurs:0 :254169411 overruns:0 f=
rame:0
>>           TX packets:4 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 lg file transmission:1000=20
>>           Octets re=E7us:3307330968 (3.3 GB) Octets transmis:1368 (1=
=2E3 KB)
>=20
> I stay in the states too much.  I love seeing net stats in French.  :=
-)

Ok :)

>=20
>>
>> How and when multi queue rx can really start to use several cpus ?
>=20
> If you're sending one flow to many consumers, it's still one flow.  E=
ven=20
> using RSS won't help, since it requires differing flows to spread loa=
d =20
> (5-tuple matches for flow distribution).

Hm... I can try varying both src and dst on my pktgen test.

Thanks
