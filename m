From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Fri, 21 Jan 2011 12:51:49 +0100
Message-ID: <1295610709.2601.35.camel@edumazet-laptop>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
	 <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>,
	Jon Zhou <jon.zhou@jdsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: juice@swagman.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:38722 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200Ab1AULvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 06:51:54 -0500
Received: by wwi17 with SMTP id 17so572437wwi.1
        for <netdev@vger.kernel.org>; Fri, 21 Jan 2011 03:51:53 -0800 (PST)
In-Reply-To: <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 janvier 2011 =C3=A0 13:44 +0200, juice a =C3=A9crit :

> Hi again.
>=20
> It has been a while since last time I got to be able to test this
> again, as there have been some other matters at hand.
> However, now I managed to rerun my tests in several different kernels=
=2E
>=20
> I am using now a PCIe Intel e1000e card, that should be able to handl=
e
> the needed traffic amount.
>=20
> The statistics that I get are as follows:
>=20
> kernel 2.6.32-27 (ubuntu 10.10 default)
>     pktgen:           750064pps 360Mb/sec (360030720bps)
>     AX4000 analyser:  Total bitrate:             383.879 MBits/s
>                       Bandwidth:                 38.39% GE
>                       Average packet intereval:  1.33 us
>=20
> kernel 2.6.37 (latest stable from kernel.org)
>     pktgen:           786848pps 377Mb/sec (377687040bps)
>     AX4000 analyser:  Total bitrate:             402.904 MBits/s
>                       Bandwidth:                 40.29% GE
>                       Average packet intereval:  1.27 us
>=20
> kernel 2.6.38-rc1 (latest from kernel.org)
>     pktgen:           795297pps 381Mb/sec (381742560bps)
>     AX4000 analyser:  Total bitrate:             407.117 MBits/s
>                       Bandwidth:                 40.72% GE
>                       Average packet intereval:  1.26 us
>=20
>=20

=2E..

> pktgen:
>=20
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
>      started: 77203892067us  stopped: 77216465982us idle: 1325us
>      seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
>      cur_saddr: 0x0  cur_daddr: 0x20b0a0a
>      cur_udp_dst: 9  cur_udp_src: 9
>      cur_queue_map: 0
>      flows: 0
> Result: OK: 12573914(c12572589+d1325) nsec, 10000000 (60byte,0frags)
>   795297pps 381Mb/sec (381742560bps) errors: 0
>=20
>=20
> AX4000 analyser:
>=20
>    Total bitrate:             407.117 MBits/s
>    Bandwidth:                 40.72% GE
>    Average packet intereval:  1.26 us
>=20
>=20

You should try

CLONE_SKB=3D"clone_skb 10"
=2E..
pgset "$CLONE_SKB"


Because I suspect you hit a performance problem on skb
allocation/filling/use/freeing

You can use perf tool to get some performance profile while your pktgen
session is running

# cd tools/perf
# make
=2E..
# ./perf top



