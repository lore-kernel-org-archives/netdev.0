From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH 5/8] af_unix: find the recipients of a multicast group
Date: Fri, 21 Jan 2011 17:24:20 +0000
Message-ID: <20110121172420.7ac74133@chocolatine.cbg.collabora.co.uk>
References: <20110121143751.57b1453d@chocolatine.cbg.collabora.co.uk>
	<1295620788-6002-5-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ian Molton <ian.molton@collabora.co.uk>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295620788-6002-5-git-send-email-alban.crequy@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[drop Cc on linux-doc]

I've got a this message with my multicast patches:

[  109.314741] =================================
[  109.316007] [ INFO: inconsistent lock state ]
[  109.316007] 2.6.38-rc1+ #14
[  109.316007] ---------------------------------
[  109.316007] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[  109.316007] ksoftirqd/1/9 [HC0[0]:SC1[1]:HE0:SE0] takes:
[  109.316007]  (&af_unix_sk_receive_queue_lock_key){+.?...}, at: [<c1256028>] skb_dequeue+0x12/0x4a
[  109.316007] {SOFTIRQ-ON-W} state was registered at:
[  109.316007]   [<c105b9b9>] __lock_acquire+0x2df/0xb95
[  109.316007]   [<c105c334>] lock_acquire+0xc5/0xe6
[  109.316007]   [<c12fd21d>] _raw_spin_lock+0x33/0x40
[  109.316007]   [<e080cbc8>] unix_stream_connect+0x34f/0x3d5 [unix]
[  109.316007]   [<c1250918>] sys_connect+0x7c/0xb2
[  109.316007]   [<c125169e>] sys_socketcall+0xb0/0x289
[  109.316007]   [<c12fdb4c>] syscall_call+0x7/0xb
[  109.316007] irq event stamp: 463879
[  109.316007] hardirqs last  enabled at (463878): [<c10c8d3c>] kmem_cache_free+0xa4/0xe2
[  109.316007] hardirqs last disabled at (463879): [<c12fd2ed>] _raw_spin_lock_irqsave+0x1d/0x57
[  109.316007] softirqs last  enabled at (463638): [<c10385d9>] __do_softirq+0x17c/0x190
[  109.316007] softirqs last disabled at (463641): [<c1004bd3>] do_softirq+0x60/0xb9
[  109.316007] 
[  109.316007] other info that might help us debug this:
[  109.316007] no locks held by ksoftirqd/1/9.
[  109.316007] 
[  109.316007] stack backtrace:
[  109.316007] Pid: 9, comm: ksoftirqd/1 Not tainted 2.6.38-rc1+ #14
[  109.316007] Call Trace:
[  109.316007]  [<c105a70f>] ? valid_state+0x168/0x174
[  109.316007]  [<c105a803>] ? mark_lock+0xe8/0x1e8
[  109.316007]  [<c105aefb>] ? check_usage_forwards+0x0/0x77
[  109.316007]  [<c105b94b>] ? __lock_acquire+0x271/0xb95
[  109.316007]  [<c1059af3>] ? register_lock_class+0x17/0x2a4
[  109.316007]  [<c105a739>] ? mark_lock+0x1e/0x1e8
[  109.316007]  [<c1059787>] ? trace_hardirqs_off+0xb/0xd
[  109.316007]  [<c105ace5>] ? debug_check_no_locks_freed+0x115/0x12d
[  109.316007]  [<c1256028>] ? skb_dequeue+0x12/0x4a
[  109.316007]  [<c105c334>] ? lock_acquire+0xc5/0xe6
[  109.316007]  [<c1256028>] ? skb_dequeue+0x12/0x4a
[  109.316007]  [<c12fd317>] ? _raw_spin_lock_irqsave+0x47/0x57
[  109.316007]  [<c1256028>] ? skb_dequeue+0x12/0x4a
[  109.316007]  [<c1256028>] ? skb_dequeue+0x12/0x4a
[  109.316007]  [<c1256a75>] ? skb_queue_purge+0x14/0x1b
[  109.316007]  [<e080cc62>] ? unix_sock_destructor+0x14/0xb6 [unix]
[  109.316007]  [<c12532fe>] ? __sk_free+0x17/0x13f
[  109.316007]  [<c105ab89>] ? trace_hardirqs_on_caller+0xeb/0x125
[  109.316007]  [<c1253488>] ? sk_free+0x16/0x18
[  109.316007]  [<e0809f74>] ? sock_put+0x13/0x15 [unix]
[  109.316007]  [<e080a107>] ? kfree_sock_set+0x21/0x36 [unix]
[  109.316007]  [<e080a127>] ? sock_set_reclaim+0xb/0xd [unix]
[  109.316007]  [<c1080068>] ? __rcu_process_callbacks+0x176/0x26b
[  109.316007]  [<c108017b>] ? rcu_process_callbacks+0x1e/0x3b
[  109.316007]  [<c103850e>] ? __do_softirq+0xb1/0x190
[  109.316007]  [<c103845d>] ? __do_softirq+0x0/0x190
[  109.316007]  <IRQ>  [<c1037d27>] ? run_ksoftirqd+0x57/0xd3
[  109.316007]  [<c1037cd0>] ? run_ksoftirqd+0x0/0xd3
[  109.316007]  [<c104a930>] ? kthread+0x6d/0x72
[  109.316007]  [<c104a8c3>] ? kthread+0x0/0x72
[  109.316007]  [<c1003742>] ? kernel_thread_helper+0x6/0x10

The socket is released and skb is dequeued in a call_rcu() callback:

> +	/* Take the lock to insert the new list but take the opportunity to do
> +	 * some garbage collection on outdated lists */
> +	spin_lock(&unix_multicast_lock);
> +	hlist_for_each_entry_rcu(del_set, pos, &group->mcast_members_lists,
> +			     list) {
> +		if (down_trylock(&del_set->sem)) {
> +			/* the list is being used by someone else */
> +			continue;
> +		}
> +		if (del_set->generation < generation) {
> +			hlist_del_rcu(&del_set->list);
> +			call_rcu(&del_set->rcu, sock_set_reclaim);

The purpose of that chunk is to release outdated struct sock_set soon
enough instead of doing it in destroy_mcast_group(). So senders of
multicast messages don't have to iterate on outdated sock_set when
they are looking for an available set of sockets.

In af_unix.c, lockdep annotations (a09785a2):
/*
 * AF_UNIX sockets do not interact with hardware, hence they
 * dont trigger interrupts - so it's safe for them to have
 * bh-unsafe locking for their sk_receive_queue.lock. Split off
 * this special lock-class by reinitializing the spinlock key:
 */
static struct lock_class_key af_unix_sk_receive_queue_lock_key;

       lockdep_set_class(&sk->sk_receive_queue.lock,
                               &af_unix_sk_receive_queue_lock_key);


I don't know if I should avoid releasing sockets in RCU callbacks or
update the lockdep annotations.

-- 
Alban
