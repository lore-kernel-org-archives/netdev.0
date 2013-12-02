From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: tbf: fix calculation of max_size
Date: Mon, 02 Dec 2013 11:45:34 -0500 (EST)
Message-ID: <20131202.114534.2139333951615698198.davem@davemloft.net>
References: <1385318452.10637.116.camel@edumazet-glaptop2.roam.corp.google.com>
	<5292C76E.1070701@huawei.com>
	<52933CC7.9070805@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018Ab3LBQqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 11:46:17 -0500
In-Reply-To: <52933CC7.9070805@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Mon, 25 Nov 2013 20:04:23 +0800

> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> Current max_size is caluated from rate table. Now, the rate table
> has been replaced and it's wrong to caculate max_size based on this
> rate table. It can lead wrong calculation of max_size.
> 
> The burst in kernel may be lower than user asked, because burst may gets
> some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
> and it seems we cannot avoid this loss. And burst's value(max_size) based
> on rate table may be equal user asked. If a packet's length is max_size,
> this packet will be stalled in tbf_dequeue() because its length is above
> the burst in kernel so that it cannot get enough tokens. The max_size guards
> against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().
> 
> This patch fixes the calculation of max_size by using psched_l2t_ns() and
> q->buffer to recalculate burst(max_size).
> 
> Also, add support to get burst from userland directly. We can avoid loss
> in byte-to-time transform by using burst directly. Iproute2 will need a
> patch to send burst to kernel.
> 
> Suggested-by: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

I don't see why you need to add the userland explicit burst capability
to fix the calculation of max_size.

These two things are separate, the new netlink attributes are a new
feature.

Therefore, please submit these two things separately.  First, submit
the pure max_size bug fix for 'net'.  Then when I open 'net-next' back
up you can submit the support for the new netlink attributes.

Thanks.
