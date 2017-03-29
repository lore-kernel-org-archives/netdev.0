From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix refcount leak on force commit.
Date: Tue, 28 Mar 2017 21:56:43 -0700 (PDT)
Message-ID: <20170328.215643.1957601529868893432.davem@davemloft.net>
References: <1490725526-21075-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, joe@ovn.org, pshelar@ovn.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41678 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752393AbdC2E4u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 00:56:50 -0400
In-Reply-To: <1490725526-21075-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Tue, 28 Mar 2017 11:25:26 -0700

> The reference count held for skb needs to be released when the skb's
> nfct pointer is cleared regardless of if nf_ct_delete() is called or
> not.
> 
> Failing to release the skb's reference cound led to deferred conntrack
> cleanup spinning forever within nf_conntrack_cleanup_net_list() when
> cleaning up a network namespace:
> 
>    kworker/u16:0-19025 [004] 45981067.173642: sched_switch: kworker/u16:0:19025 [120] R ==> rcu_preempt:7 [120]
>    kworker/u16:0-19025 [004] 45981067.173651: kernel_stack: <stack trace>
> => ___preempt_schedule (ffffffffa001ed36)
> => _raw_spin_unlock_bh (ffffffffa0713290)
> => nf_ct_iterate_cleanup (ffffffffc00a4454)
> => nf_conntrack_cleanup_net_list (ffffffffc00a5e1e)
> => nf_conntrack_pernet_exit (ffffffffc00a63dd)
> => ops_exit_list.isra.1 (ffffffffa06075f3)
> => cleanup_net (ffffffffa0607df0)
> => process_one_work (ffffffffa0084c31)
> => worker_thread (ffffffffa008592b)
> => kthread (ffffffffa008bee2)
> => ret_from_fork (ffffffffa071b67c)
> 
> Fixes: dd41d33f0b03 ("openvswitch: Add force commit.")
> Reported-by: Yang Song <yangsong@vmware.com>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied, thanks.
