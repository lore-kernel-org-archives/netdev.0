From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] prevent pktgen from using bad tx queue
Date: Wed, 13 Aug 2008 15:16:10 -0700 (PDT)
Message-ID: <20080813.151610.127721963.davem@davemloft.net>
References: <48A34541.6000008@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54167
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751654AbYHMWQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 18:16:09 -0400
In-Reply-To: <48A34541.6000008@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 13 Aug 2008 16:34:09 -0400

> 
> With the new multi-queue transmit code, it is possible to accidentally
> make pktgen pick a non-existing tx queue simply by using a stale
> script to drive pktgen.  Access to this non-existing tx queue will
> then trigger a bad memory access and kill the machine.
> 
> For example, setting "queue_map_max 2" will cause my machine to die
> when accessing a garbage spinlock in the non-existing tx queue:
> 
> BUG: spinlock bad magic on CPU#0, kpktgend_0/564
>   lock: ffff88001ddf6718, .magic: ffffffff, .owner: /-1, .owner_cpu: 0
> Pid: 564, comm: kpktgend_0 Not tainted 2.6.27-rc3 #35
> 
> Call Trace:
>   [<ffffffff803a1228>] spin_bug+0xa4/0xac
>   [<ffffffff803a1253>] _raw_spin_lock+0x23/0x123
>   [<ffffffff8055b06f>] _spin_lock_bh+0x17/0x1b
>   [<ffffffff804cb57d>] pktgen_thread_worker+0xa97/0x1002
>   [<ffffffff8022874d>] ? finish_task_switch+0x38/0x97
>   [<ffffffff80242077>] ? autoremove_wake_function+0x0/0x36
>   [<ffffffff80242077>] ? autoremove_wake_function+0x0/0x36
>   [<ffffffff804caae6>] ? pktgen_thread_worker+0x0/0x1002
>   [<ffffffff80241a40>] kthread+0x44/0x6d
>   [<ffffffff8020c399>] child_rip+0xa/0x11
>   [<ffffffff802419fc>] ? kthread+0x0/0x6d
>   [<ffffffff8020c38f>] ? child_rip+0x0/0x11
> 
> The attached patch adds some sanity checking to prevent
> these sorts of configuration errors.
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>

Looks good, applied, thanks Andrew.
