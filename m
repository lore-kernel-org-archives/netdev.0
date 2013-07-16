From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net_sched: precision problem of TBF/HTB
Date: Mon, 15 Jul 2013 21:50:01 -0700
Message-ID: <1373950201.10804.103.camel@edumazet-glaptop>
References: <51E4C815.9000408@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:65175 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab3GPEuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 00:50:03 -0400
Received: by mail-pa0-f44.google.com with SMTP id lj1so355990pab.3
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 21:50:02 -0700 (PDT)
In-Reply-To: <51E4C815.9000408@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 12:12 +0800, Yang Yingliang wrote:
> Hi, Eric
> Commit 1def9238d4aa2 (net_sched: more precise pkt_len computation)
> makes more precise transfer bytes by taking account of headers in
> qdisc_skb_cb(skb)->pkt_len, but this introduces a problem with
> calculating bandwidth in userland.
> 
This changed nothing to userland.

> When calculating bandwidth in userland, it's not include headers'
> bytes. From the user's perspective, it's not a correct bandwidth.
> 


> Shall we need take account of headers in qdisc_skb_cb(skb)->pkt_len or
> just skb->len?
> 
These values are not accessible from userland, unless you capture
packets with a sniffer (tcpdump or something like that)

> Example:
> tc qdisc add dev $DEV root handle 1: tbf latency 50ms burst 500kB rate
> 500mbit mtu 64k
> 
> iperf -c host -t 30 -i 10
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec   571 MBytes   479 Mbits/sec
> [  3] 10.0-20.0 sec   570 MBytes   478 Mbits/sec
> [  3] 20.0-30.0 sec   570 MBytes   478 Mbits/sec
> [  3]  0.0-30.0 sec  1.67 GBytes   478 Mbits/sec


iperf only measures the amount of payload, and probably do not care of
headers.

You cannot accurately measure bandwidth from userland, unless making
assumptions (or getting them from the stack) on header sizes (IP + TCP),
MSS value, and retransmits.
