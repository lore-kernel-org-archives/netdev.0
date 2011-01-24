From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Mon, 24 Jan 2011 10:18:13 +0100
Message-ID: <1295860693.2755.17.camel@edumazet-laptop>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
	 <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
	 <alpine.WNT.2.00.1101211400000.5816@JBRANDEB-DESK2.amr.corp.intel.com>
	 <8ad1defdf427ceb7af94fad4d216b006.squirrel@www.liukuma.net>
	 <30747065682effddc661b8cd235553d9.squirrel@www.liukuma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Loke, Chetan" <chetan.loke@netscout.com>,
	Jon Zhou <jon.zhou@jdsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: juice@swagman.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39159 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab1AXJSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 04:18:25 -0500
Received: by bwz15 with SMTP id 15so3354484bwz.19
        for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 01:18:24 -0800 (PST)
In-Reply-To: <30747065682effddc661b8cd235553d9.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 24 janvier 2011 =C3=A0 10:10 +0200, juice a =C3=A9crit :
> >> you may also want to try reducing the tx descriptor ring count to =
128
> >> using ethtool, and change the ethtool -C rx-usecs 20 setting, try
> >> 20,30,40,50,60
> >
> > So this could up my current network card to a little faster?
> > If I can reach 1.1Mpackets/s, thats about 560Mbits/s. At least it w=
ould
> > get me a little closet to what I am trying to achieve.
> >
>=20
> I tried these tunings, and it turns out that I am able to get the bes=
t
> performance with pktgen when I set the options "ethtool -G eth1 tx 12=
8"
> and "ethtool -C eth1 rx-usecs 10". Anything different will lower the =
TX
> performance.
>=20

That (rx-usecs 10) makes no sense.
pktgen sends packets.
You should not receive packets ?

> Now I can get these rates:
>=20
> root@d8labralinux:/var/home/juice/pkt_test# cat /proc/net/pktgen/eth1
> Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
>      frags: 0  delay: 0  clone_skb: 1  ifname: eth1
>      flows: 0 flowlen: 0
>      queue_map_min: 0  queue_map_max: 0
>      dst_min: 10.10.11.2  dst_max:
>         src_min:   src_max:
>      src_mac: 00:1b:21:7c:e5:b1 dst_mac: 00:04:23:08:91:dc
>      udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
>      src_mac_count: 0  dst_mac_count: 0
>      Flags:
> Current:
>      pkts-sofar: 10000000  errors: 0
>      started: 1205660106us  stopped: 1218005650us idle: 804us
>      seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
>      cur_saddr: 0x0  cur_daddr: 0x20b0a0a
>      cur_udp_dst: 9  cur_udp_src: 9
>      cur_queue_map: 0
>      flows: 0
> Result: OK: 12345544(c12344739+d804) nsec, 10000000 (60byte,0frags)
>   810008pps 388Mb/sec (388803840bps) errors: 0
>=20
> AX4000:
>   Total bitrate:             414.629 MBits/s
>   Packet rate:               809824 packets/s
>   Bandwidth:                 41.46% GE
>   Average packet intereval:  1.23 us
>=20
> This is a bit better than the previous maxim of 750064pps / 360Mb/sec
> that I was able to achieve without tuning parameters with ethtool, bu=
t
> still not near the 1.1Mpacks/s that shoud be doable with my card?
>=20
> Are there other tunings or alternate driver that I could use to get t=
he
> best performance out of the card? Basically what puzzles me is the fa=
ct
> that I can get a lot better performance using larger packets, so that
> suggests to me that the bottleneck cannot be the PCIe interface, as I=
 can
> push enough data through it. Is there any way of doing larger transfe=
rs
> on the bus, like grouping many smaller packets together to avoid the
> problems caused by so many TX interrupts?
>=20

What matters is not size of packets, but number of transactions (packet=
s
per second)

You need a x4 or x8 connector to get more transactions per second, by a=
n
order of magnitude, not 10% or 15% ;)

TX interrupts are already 'grouped', one for ~50 packets

ethtool -c :

tx-usecs: 72
tx-frames: 53
tx-usecs-irq: 0
tx-frames-irq: 53



