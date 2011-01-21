From: "juice" <juice@swagman.org>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Fri, 21 Jan 2011 14:12:33 +0200
Message-ID: <37bfb9ca79c2325ec4b70033f509200a.squirrel@www.liukuma.net>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
    <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
    <1295610709.2601.35.camel@edumazet-laptop>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Loke, Chetan" <chetan.loke@netscout.com>,
	"Jon Zhou" <jon.zhou@jdsu.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:24732 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754403Ab1AUMMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 07:12:39 -0500
In-Reply-To: <1295610709.2601.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Le vendredi 21 janvier 2011 =C3=A0 13:44 +0200, juice a =C3=A9crit :
>
>
> You should try
>
> CLONE_SKB=3D"clone_skb 10"
> ...
> pgset "$CLONE_SKB"
>
>
> Because I suspect you hit a performance problem on skb
> allocation/filling/use/freeing

Actually, that makes the performance worse:
(Now I tried it with kernel 2.6.37, which is currently running)

root@d8labralinux:/var/home/juice/pkt_test# cat /proc/net/pktgen/eth1
Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 10  ifname: eth1
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
     started: 2555660074us  stopped: 2569239323us idle: 3484us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 13579248(c13575763+d3484) nsec, 10000000 (60byte,0frags)
  736417pps 353Mb/sec (353480160bps) errors: 0


> You can use perf tool to get some performance profile while your pktg=
en
> session is running
>
> # cd tools/perf
> # make
> ...
> # ./perf top
>

I can try that.
Where do I get the performance profiler tool?


Yours, Jussi Ohenoja


