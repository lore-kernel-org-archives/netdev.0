From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next 1/1] net_sched: Introduce skbmod action
Date: Thu, 15 Sep 2016 19:34:05 -0400 (EDT)
Message-ID: <20160915.193405.2033388300516404267.davem@davemloft.net>
References: <1473725589-27110-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        john.r.fastabend@intel.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58804 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757179AbcIOXeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:34:08 -0400
In-Reply-To: <1473725589-27110-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 12 Sep 2016 20:13:09 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> This action is intended to be an upgrade from a usability perspective
> from pedit (as well as operational debugability).
> Compare this:
> 
> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action pedit munge offset -14 u8 set 0x02 \
> munge offset -13 u8 set 0x15 \
> munge offset -12 u8 set 0x15 \
> munge offset -11 u8 set 0x15 \
> munge offset -10 u16 set 0x1515 \
> pipe
> 
> to:
> 
> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action skbmod dmac 02:15:15:15:15:15
> 
> Also try to do a MAC address swap with pedit or worse
> try to debug a policy with destination mac, source mac and
> etherype. Then make few rules out of those and you'll get my point.
> 
> In the future common use cases on pedit can be migrated to this action
> (as an example different fields in ip v4/6, transports like tcp/udp/sctp
> etc). For this first cut, this allows modifying basic ethernet header.
> 
> The most important ethernet use case at the moment is when redirecting or
> mirroring packets to a remote machine. The dst mac address needs a re-write
> so that it doesnt get dropped or confuse an interconnecting (learning) switch
> or dropped by a target machine (which looks at the dst mac). And at times
> when flipping back the packet a swap of the MAC addresses is needed.
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks.
