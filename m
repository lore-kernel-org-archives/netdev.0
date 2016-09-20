From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] net sched ife action: Introduce skb
 tcindex metadata encap decap
Date: Mon, 19 Sep 2016 21:57:15 -0400 (EDT)
Message-ID: <20160919.215715.42528336162002380.davem@davemloft.net>
References: <1474198303-10645-1-git-send-email-jhs@emojatatu.com>
        <1474198303-10645-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40760 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932327AbcITB5X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 21:57:23 -0400
In-Reply-To: <1474198303-10645-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 18 Sep 2016 07:31:43 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Sample use case of how this is encoded:
> user space via tuntap (or a connected VM/Machine/container)
> encodes the tcindex TLV.
> 
> Sample use case of decoding:
> IFE action decodes it and the skb->tc_index is then used to classify.
> So something like this for encoded ICMP packets:
> 
> .. first decode then reclassify... skb->tcindex will be set
> sudo $TC filter add dev $ETH parent ffff: prio 2 protocol 0xbeef \
> u32 match u32 0 0 flowid 1:1 \
> action ife decode reclassify
> 
> ...next match the decode icmp packet...
> sudo $TC filter add dev $ETH parent ffff: prio 4 protocol ip \
> u32 match ip protocol 1 0xff flowid 1:1 \
> action continue
> 
> ... last classify it using the tcindex classifier and do someaction..
> sudo $TC filter add dev $ETH parent ffff: prio 5 protocol ip \
> handle 0x11 tcindex classid 1:1 \
> action blah..
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
