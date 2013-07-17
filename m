From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: net_sched: precision problem of TBF/HTB
Date: Wed, 17 Jul 2013 09:41:03 +0800
Message-ID: <51E5F62F.8080906@huawei.com>
References: <51E4C815.9000408@huawei.com> <1373950201.10804.103.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yang Yingliang <yangyingliang@huawei.com>,
	Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:29170 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971Ab3GQBlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 21:41:36 -0400
In-Reply-To: <1373950201.10804.103.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/7/16 12:50, Eric Dumazet wrote:
> On Tue, 2013-07-16 at 12:12 +0800, Yang Yingliang wrote:
>> Hi, Eric
>> Commit 1def9238d4aa2 (net_sched: more precise pkt_len computation)
>> makes more precise transfer bytes by taking account of headers in
>> qdisc_skb_cb(skb)->pkt_len, but this introduces a problem with
>> calculating bandwidth in userland.
>>
> This changed nothing to userland.
> 
>> When calculating bandwidth in userland, it's not include headers'
>> bytes. From the user's perspective, it's not a correct bandwidth.
>>
> 
> 
>> Shall we need take account of headers in qdisc_skb_cb(skb)->pkt_len or
>> just skb->len?
>>
> These values are not accessible from userland, unless you capture
> packets with a sniffer (tcpdump or something like that)
> 
>> Example:
>> tc qdisc add dev $DEV root handle 1: tbf latency 50ms burst 500kB rate
>> 500mbit mtu 64k
>>
>> iperf -c host -t 30 -i 10
>> [ ID] Interval       Transfer     Bandwidth
>> [  3]  0.0-10.0 sec   571 MBytes   479 Mbits/sec
>> [  3] 10.0-20.0 sec   570 MBytes   478 Mbits/sec
>> [  3] 20.0-30.0 sec   570 MBytes   478 Mbits/sec
>> [  3]  0.0-30.0 sec  1.67 GBytes   478 Mbits/sec
> 
> 
> iperf only measures the amount of payload, and probably do not care of
> headers.
> 
> You cannot accurately measure bandwidth from userland, unless making
> assumptions (or getting them from the stack) on header sizes (IP + TCP),
> MSS value, and retransmits.
> 
> 

ok, for the further, can you give me some advise for how calculate the bandwidth for net link.
for example,what kind of tools is better.

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
