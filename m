From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] af_unix: conditionally use freezable blocking
 calls in read
Date: Fri, 18 Nov 2016 13:59:15 -0500 (EST)
Message-ID: <20161118.135915.760650991089630301.davem@davemloft.net>
References: <1479426926-28197-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, tj@kernel.org,
        ccross@android.com, rafael.j.wysocki@intel.com,
        hannes@stressinduktion.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39038 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752419AbcKRS7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 13:59:16 -0500
In-Reply-To: <1479426926-28197-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 17 Nov 2016 15:55:26 -0800

> Commit 2b15af6f95 ("af_unix: use freezable blocking calls in read")
> converts schedule_timeout() to its freezable version, it was probably
> correct at that time, but later, commit 2b514574f7e8
> ("net: af_unix: implement splice for stream af_unix sockets") breaks
> the strong requirement for a freezable sleep, according to
> commit 0f9548ca1091:
> 
>     We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
>     deadlock if the lock is later acquired in the suspend or hibernate path
>     (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
>     cgroup_freezer if a lock is held inside a frozen cgroup that is later
>     acquired by a process outside that group.
> 
> The pipe_lock is still held at that point.
> 
> So use freezable version only for the recvmsg call path, avoid impact for
> Android.
> 
> Fixes: 2b514574f7e8 ("net: af_unix: implement splice for stream af_unix sockets")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Colin Cross <ccross@android.com>
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
