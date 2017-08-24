From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: remove tc class reference counting
Date: Thu, 24 Aug 2017 12:32:20 -0700 (PDT)
Message-ID: <20170824.123220.2250866539237700218.davem@davemloft.net>
References: <20170823043810.17602-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751615AbdHXTcV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 15:32:21 -0400
In-Reply-To: <20170823043810.17602-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 22 Aug 2017 21:38:10 -0700

> For TC classes, their ->get() and ->put() are always paired, and the
> reference counting is completely useless, because:
> 
> 1) For class modification and dumping paths, we already hold RTNL lock,
>    so all of these ->get(),->change(),->put() are atomic.
> 
> 2) For filter bindiing/unbinding, we use other reference counter than
>    this one, and they should have RTNL lock too.
> 
> 3) For ->qlen_notify(), it is special because it is called on ->enqueue()
>    path, but we already hold qdisc tree lock there, and we hold this
>    tree lock when graft or delete the class too, so it should not be gone
>    or changed until we release the tree lock.
> 
> Therefore, this patch removes ->get() and ->put(), but:
> 
> 1) Adds a new ->find() to find the pointer to a class by classid, no
>    refcnt.
> 
> 2) Move the original class destroy upon the last refcnt into ->delete(),
>    right after releasing tree lock. This is fine because the class is
>    already removed from hash when holding the lock.
> 
> For those who also use ->put() as ->unbind(), just rename them to reflect
> this change.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This one looks good to me.

Jamal, please give it a quick look over and review.

Thanks!
