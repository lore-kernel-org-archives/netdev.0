From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 13:30:42 +0300
Message-ID: <4B0A6452.2020508@bigtelecom.ru>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com> <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:33168 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756632AbZKWKal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 05:30:41 -0500
In-Reply-To: <4B0A6218.9040303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric. I paly with this card 3 weeks and maybe help for you :)

By default intel flower use only first cpu. Its strange.
If we add affinity to single cpu core for interrupt its will use this C=
PU core.
If we add affinity to two or more cpus its applying but don't work.
See ixgbe driver README from intel.com. Its have param for RSS flower. =
I think its do this :)
Also driver from intel.com have script for split RxTx->Cpu core but you=
 must replace "tx rx" in code to "TxRx".

P.S. Please also see if you can and wont:
On e1000 and x86 kernel + 2xXeon 2core my TC rules load 3 min
On ixgbe and X86_64 kernel + 4xXeon 6core my TC rules load more 15 mins=
!
Its 64 bit regression?

Tc rules i can send to you if you ask me for it! Thanks!

Slavon


> Hi Peter
>=20
> I tried a pktgen stress on 82599EB card and could not split RX load o=
n multiple cpus.
>=20
> Setup is :
>=20
> One 82599 card with fiber0 looped to fiber1, 10Gb link mode.
> machine is a HPDL380 G6 with dual quadcore E5530 @2.4GHz (16 logical =
cpus)
>=20
> I use one pktgen thread sending to fiber0 one many dst IP, and checke=
d that fiber1
> was using many RX queues :
>=20
> grep fiber1 /proc/interrupts=20
> 117:       1301      13060          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-0
> 118:        601       1402          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-1
> 119:        634        832          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-2
> 120:        601       1303          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-3
> 121:        620       1246          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-4
> 122:       1287      13088          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-5
> 123:        606       1354          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-6
> 124:        653        827          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-7
> 125:        639        825          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-8
> 126:        596       1199          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-9
> 127:       2013      24800          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-10
> 128:        648       1353          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-11
> 129:        601       1123          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-12
> 130:        625        834          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-13
> 131:        665       1409          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-14
> 132:       2637      31699          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1-TxR=
x-15
> 133:          1          0          0          0          0          =
0          0          0          0          0          0          0    =
      0          0          0          0   PCI-MSI-edge      fiber1:lsc
>=20
>=20
>=20
> But only one CPU (CPU1) had a softirq running, 100%, and many frames =
were dropped
>=20
> root@demodl380g6:/usr/src# ifconfig fiber0
> fiber0    Link encap:Ethernet  HWaddr 00:1b:21:4a:fe:54 =20
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           Packets re=E7us:4 erreurs:0 :0 overruns:0 frame:0
>           TX packets:309291576 errors:0 dropped:0 overruns:0 carrier:=
0
>           collisions:0 lg file transmission:1000=20
>           Octets re=E7us:1368 (1.3 KB) Octets transmis:18557495682 (1=
8.5 GB)
>=20
> root@demodl380g6:/usr/src# ifconfig fiber1
> fiber1    Link encap:Ethernet  HWaddr 00:1b:21:4a:fe:55 =20
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           Packets re=E7us:55122164 erreurs:0 :254169411 overruns:0 fr=
ame:0
>           TX packets:4 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 lg file transmission:1000=20
>           Octets re=E7us:3307330968 (3.3 GB) Octets transmis:1368 (1.=
3 KB)
>=20
>=20
> How and when multi queue rx can really start to use several cpus ?
>=20
> Thanks
> Eric
>=20
>=20
> pktgen script :
>=20
> pgset()
> {
>     local result
>=20
>     echo $1 > $PGDEV
>=20
>     result=3D`cat $PGDEV | fgrep "Result: OK:"`
>     if [ "$result" =3D "" ]; then
>          cat $PGDEV | fgrep Result:
>     fi
> }
>=20
> pg()
> {
>     echo inject > $PGDEV
>     cat $PGDEV
> }
>=20
>=20
> PGDEV=3D/proc/net/pktgen/kpktgend_4
>=20
>  echo "Adding fiber0"
>  pgset "add_device fiber0@0"
>=20
>=20
> CLONE_SKB=3D"clone_skb 15"
>=20
> PKT_SIZE=3D"pkt_size 60"
>=20
>=20
> COUNT=3D"count 100000000"
> DELAY=3D"delay 0"
>=20
> PGDEV=3D/proc/net/pktgen/fiber0@0
>   echo "Configuring $PGDEV"
>  pgset "$COUNT"
>  pgset "$CLONE_SKB"
>  pgset "$PKT_SIZE"
>  pgset "$DELAY"
>  pgset "queue_map_min 0"
>  pgset "queue_map_max 7"
>  pgset "dst_min 192.168.0.2"
>  pgset "dst_max 192.168.0.250"
>  pgset "src_min 192.168.0.1"
>  pgset "src_max 192.168.0.1"
>  pgset "dst_mac  00:1b:21:4a:fe:55"
>=20
>=20
> # Time to run
> PGDEV=3D/proc/net/pktgen/pgctrl
>=20
>  echo "Running... ctrl^C to stop"
>  pgset "start"=20
>  echo "Done"
>=20
> # Result can be vieved in /proc/net/pktgen/fiber0@0
>=20
> for f in fiber0@0
> do
>  cat /proc/net/pktgen/$f
> done
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

