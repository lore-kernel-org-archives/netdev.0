From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 00/16] net_sched: fix races with RCU callbacks
Date: Sun, 29 Oct 2017 23:41:57 +0900 (KST)
Message-ID: <20171029.234157.1495300486874041519.davem@davemloft.net>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrism@mellanox.com, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, jhs@mojatatu.com,
        paulmck@linux.vnet.ibm.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50752 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbdJ2OmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 10:42:03 -0400
In-Reply-To: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 26 Oct 2017 18:24:27 -0700

> Recently, the RCU callbacks used in TC filters and TC actions keep
> drawing my attention, they introduce at least 4 race condition bugs:
 ...
> As suggested by Paul, we could defer the work to a workqueue and
> gain the permission of holding RTNL again without any performance
> impact, however, in tcf_block_put() we could have a deadlock when
> flushing workqueue while hodling RTNL lock, the trick here is to
> defer the work itself in workqueue and make it queued after all
> other works so that we keep the same ordering to avoid any
> use-after-free. Please see the first patch for details.
> 
> Patch 1 introduces the infrastructure, patch 2~12 move each
> tc filter to the new tc filter workqueue, patch 13 adds
> an assertion to catch potential bugs like this, patch 14
> closes another rcu callback race, patch 15 and patch 16 add
> new test cases.

I know Eric has some reservations about how things have become in
this layer, but we have to fix this for 'net' somehow.

So I've applied this series, thanks.
