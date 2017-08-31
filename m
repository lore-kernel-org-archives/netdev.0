From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: add reverse binding for tc class
Date: Thu, 31 Aug 2017 11:41:05 -0700 (PDT)
Message-ID: <20170831.114105.1838514102434934968.davem@davemloft.net>
References: <20170830213036.24250-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdHaSlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 14:41:09 -0400
In-Reply-To: <20170830213036.24250-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 30 Aug 2017 14:30:36 -0700

> TC filters when used as classifiers are bound to TC classes.
> However, there is a hidden difference when adding them in different
> orders:
> 
> 1. If we add tc classes before its filters, everything is fine.
>    Logically, the classes exist before we specify their ID's in
>    filters, it is easy to bind them together, just as in the current
>    code base.
> 
> 2. If we add tc filters before the tc classes they bind, we have to
>    do dynamic lookup in fast path. What's worse, this happens all
>    the time not just once, because on fast path tcf_result is passed
>    on stack, there is no way to propagate back to the one in tc filters.
> 
> This hidden difference hurts performance silently if we have many tc
> classes in hierarchy.
> 
> This patch intends to close this gap by doing the reverse binding when
> we create a new class, in this case we can actually search all the
> filters in its parent, match and fixup by classid. And because
> tcf_result is specific to each type of tc filter, we have to introduce
> a new ops for each filter to tell how to bind the class.
> 
> Note, we still can NOT totally get rid of those class lookup in
> ->enqueue() because cgroup and flow filters have no way to determine
> the classid at setup time, they still have to go through dynamic lookup.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
