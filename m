From: Yang Yingliang <yangyingliang@huawei.com>
Subject: net_sched: precision problem of TBF/HTB
Date: Tue, 16 Jul 2013 12:12:05 +0800
Message-ID: <51E4C815.9000408@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:15463 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab3GPEMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 00:12:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric
Commit 1def9238d4aa2 (net_sched: more precise pkt_len computation) makes more precise transfer bytes by taking account of headers in qdisc_skb_cb(skb)->pkt_len, but this introduces a problem with calculating bandwidth in userland.

When calculating bandwidth in userland, it's not include headers' bytes. From the user's perspective, it's not a correct bandwidth.

Shall we need take account of headers in qdisc_skb_cb(skb)->pkt_len or just skb->len?

Example:
tc qdisc add dev $DEV root handle 1: tbf latency 50ms burst 500kB rate 500mbit mtu 64k

iperf -c host -t 30 -i 10
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   571 MBytes   479 Mbits/sec
[  3] 10.0-20.0 sec   570 MBytes   478 Mbits/sec
[  3] 20.0-30.0 sec   570 MBytes   478 Mbits/sec
[  3]  0.0-30.0 sec  1.67 GBytes   478 Mbits/sec
