From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net_sched: increase drop count when packets
 are dropped
Date: Mon, 26 May 2014 21:05:52 -0700
Message-ID: <1401163552.5367.237.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401070932-12440-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vtlam@google.com, nanditad@google.com,
	davem@davemloft.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:64814 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbaE0EFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 00:05:54 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so8579066pbc.30
        for <netdev@vger.kernel.org>; Mon, 26 May 2014 21:05:53 -0700 (PDT)
In-Reply-To: <1401070932-12440-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-26 at 10:22 +0800, Yang Yingliang wrote:
> When we change limit in qdisc, if there're too many packets in the queue,
> some packets will be dropped but the drop count is not increased.

> So replace kfree_skb() with qdisc_drop() which will increase the
> drop count. hhf and fq_codel have the same problem, fix them too.
> Besides, fq_codel and hhf have a member drop_overlimit which means
> drop count because of overlimit, increase it too.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Terry Lam <vtlam@google.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> 
> ---

Problem with this patch is that you missed that all these qdiscs use a
regular dequeue() operation in this path.

So every in excess packet is going to be accounted twice after your
patch.

Once as 'normally dequeued', another time as 'dropped'

Your patch shifts a problem into another.

The example in your changelog shows this new problem.

Really I do not feel its needed to spend hours on work on this minor
problem : We would have to add parameters (slowing down the fast path),
or copy/paste the regular dequeue code (code bloat and maintenance
hassle)

So I wont Ack this patch, sorry.
