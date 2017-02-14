From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] net/mlx5e: Disable preemption when doing TC
 statistics upcall
Date: Tue, 14 Feb 2017 11:56:57 -0500 (EST)
Message-ID: <20170214.115657.701720927787143085.davem@davemloft.net>
References: <1486891291-14453-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, amir@vadai.me, roid@mellanox.com,
        netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753823AbdBNQ47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 11:56:59 -0500
In-Reply-To: <1486891291-14453-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 12 Feb 2017 11:21:31 +0200

> When called by HW offloading drivers, the TC action (e.g
> net/sched/act_mirred.c) code uses this_cpu logic, e.g
> 
>  _bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets)
> 
> per the kernel documention, preemption should be disabled, add that.
> 
> Before the fix, when running with CONFIG_PREEMPT set, we get a
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: tc/3793
> 
> asserion from the TC action (mirred) stats_update callback.
> 
> Fixes: aad7e08d39bd ('net/mlx5e: Hardware offloaded flower filter statistics support')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied and queued up for -stable, thanks Or.
