From: "juice" <juice@swagman.org>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Mon, 24 Jan 2011 10:10:08 +0200
Message-ID: <30747065682effddc661b8cd235553d9.squirrel@www.liukuma.net>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
    <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
    <alpine.WNT.2.00.1101211400000.5816@JBRANDEB-DESK2.amr.corp.intel.com>
    <8ad1defdf427ceb7af94fad4d216b006.squirrel@www.liukuma.net>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Loke, Chetan" <chetan.loke@netscout.com>,
	"Jon Zhou" <jon.zhou@jdsu.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Stephen Hemming
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:46194 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915Ab1AXIKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 03:10:17 -0500
In-Reply-To: <8ad1defdf427ceb7af94fad4d216b006.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> you may also want to try reducing the tx descriptor ring count to 128
>> using ethtool, and change the ethtool -C rx-usecs 20 setting, try
>> 20,30,40,50,60
>
> So this could up my current network card to a little faster?
> If I can reach 1.1Mpackets/s, thats about 560Mbits/s. At least it would
> get me a little closet to what I am trying to achieve.
>

I tried these tunings, and it turns out that I am able to get the best
performance with pktgen when I set the options "ethtool -G eth1 tx 128"
and "ethtool -C eth1 rx-usecs 10". Anything different will lower the TX
performance.

Now I can get these rates:

root@d8labralinux:/var/home/juice/pkt_test# cat /proc/net/pktgen/eth1
Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 1  ifname: eth1
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.10.11.2  dst_max:
        src_min:   src_max:
     src_mac: 00:1b:21:7c:e5:b1 dst_mac: 00:04:23:08:91:dc
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 10000000  errors: 0
     started: 1205660106us  stopped: 1218005650us idle: 804us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 12345544(c12344739+d804) nsec, 10000000 (60byte,0frags)
  810008pps 388Mb/sec (388803840bps) errors: 0

AX4000:
  Total bitrate:             414.629 MBits/s
  Packet rate:               809824 packets/s
  Bandwidth:                 41.46% GE
  Average packet intereval:  1.23 us

This is a bit better than the previous maxim of 750064pps / 360Mb/sec
that I was able to achieve without tuning parameters with ethtool, but
still not near the 1.1Mpacks/s that shoud be doable with my card?

Are there other tunings or alternate driver that I could use to get the
best performance out of the card? Basically what puzzles me is the fact
that I can get a lot better performance using larger packets, so that
suggests to me that the bottleneck cannot be the PCIe interface, as I can
push enough data through it. Is there any way of doing larger transfers
on the bus, like grouping many smaller packets together to avoid the
problems caused by so many TX interrupts?

Yours, Jussi Ohenoja



