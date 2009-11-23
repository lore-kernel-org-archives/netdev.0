From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: ixgbe question
Date: Mon, 23 Nov 2009 11:21:12 +0100
Message-ID: <4B0A6218.9040303@gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com> <1258968980.2697.9.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37653 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbZKWKVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 05:21:10 -0500
In-Reply-To: <1258968980.2697.9.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter

I tried a pktgen stress on 82599EB card and could not split RX load on =
multiple cpus.

Setup is :

One 82599 card with fiber0 looped to fiber1, 10Gb link mode.
machine is a HPDL380 G6 with dual quadcore E5530 @2.4GHz (16 logical cp=
us)

I use one pktgen thread sending to fiber0 one many dst IP, and checked =
that fiber1
was using many RX queues :

grep fiber1 /proc/interrupts=20
117:       1301      13060          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
0
118:        601       1402          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
1
119:        634        832          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
2
120:        601       1303          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
3
121:        620       1246          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
4
122:       1287      13088          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
5
123:        606       1354          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
6
124:        653        827          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
7
125:        639        825          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
8
126:        596       1199          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
9
127:       2013      24800          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
10
128:        648       1353          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
11
129:        601       1123          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
12
130:        625        834          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
13
131:        665       1409          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
14
132:       2637      31699          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1-TxRx-=
15
133:          1          0          0          0          0          0 =
         0          0          0          0          0          0      =
    0          0          0          0   PCI-MSI-edge      fiber1:lsc



But only one CPU (CPU1) had a softirq running, 100%, and many frames we=
re dropped

root@demodl380g6:/usr/src# ifconfig fiber0
fiber0    Link encap:Ethernet  HWaddr 00:1b:21:4a:fe:54 =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Packets re=E7us:4 erreurs:0 :0 overruns:0 frame:0
          TX packets:309291576 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 lg file transmission:1000=20
          Octets re=E7us:1368 (1.3 KB) Octets transmis:18557495682 (18.=
5 GB)

root@demodl380g6:/usr/src# ifconfig fiber1
fiber1    Link encap:Ethernet  HWaddr 00:1b:21:4a:fe:55 =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Packets re=E7us:55122164 erreurs:0 :254169411 overruns:0 fram=
e:0
          TX packets:4 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 lg file transmission:1000=20
          Octets re=E7us:3307330968 (3.3 GB) Octets transmis:1368 (1.3 =
KB)


How and when multi queue rx can really start to use several cpus ?

Thanks
Eric


pktgen script :

pgset()
{
    local result

    echo $1 > $PGDEV

    result=3D`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" =3D "" ]; then
         cat $PGDEV | fgrep Result:
    fi
}

pg()
{
    echo inject > $PGDEV
    cat $PGDEV
}


PGDEV=3D/proc/net/pktgen/kpktgend_4

 echo "Adding fiber0"
 pgset "add_device fiber0@0"


CLONE_SKB=3D"clone_skb 15"

PKT_SIZE=3D"pkt_size 60"


COUNT=3D"count 100000000"
DELAY=3D"delay 0"

PGDEV=3D/proc/net/pktgen/fiber0@0
  echo "Configuring $PGDEV"
 pgset "$COUNT"
 pgset "$CLONE_SKB"
 pgset "$PKT_SIZE"
 pgset "$DELAY"
 pgset "queue_map_min 0"
 pgset "queue_map_max 7"
 pgset "dst_min 192.168.0.2"
 pgset "dst_max 192.168.0.250"
 pgset "src_min 192.168.0.1"
 pgset "src_max 192.168.0.1"
 pgset "dst_mac  00:1b:21:4a:fe:55"


# Time to run
PGDEV=3D/proc/net/pktgen/pgctrl

 echo "Running... ctrl^C to stop"
 pgset "start"=20
 echo "Done"

# Result can be vieved in /proc/net/pktgen/fiber0@0

for f in fiber0@0
do
 cat /proc/net/pktgen/$f
done


