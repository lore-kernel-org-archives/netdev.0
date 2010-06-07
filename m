From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.35-rc2-git1 - net/mac80211/sta_info.c:125 invoked
 rcu_dereference_check() without protection!
Date: Mon, 7 Jun 2010 16:59:42 -0700
Message-ID: <20100607235941.GD2387@linux.vnet.ibm.com>
References: <AANLkTintKf_9C1sBsUac6Prvb1nWn7nWszatJ8yUb-VM@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:58504 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834Ab0FGX7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 19:59:45 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTintKf_9C1sBsUac6Prvb1nWn7nWszatJ8yUb-VM@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 07, 2010 at 02:25:44PM -0400, Miles Lane wrote:
> [   43.478812] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   43.478815] ---------------------------------------------------
> [   43.478820] net/mac80211/sta_info.c:125 invoked
> rcu_dereference_check() without protection!
> [   43.478824]
> [   43.478824] other info that might help us debug this:
> [   43.478826]
> [   43.478829]
> [   43.478830] rcu_scheduler_active = 1, debug_locks = 1
> [   43.478834] no locks held by NetworkManager/4017.

Hmmm...  Johannes's update has been merged, and it requires that callers
either be in an RCU read-side critical section or hold either the
->sta_lock or the ->sta_mtx, and this thread does none of this.

Johannes, any thoughts?

							Thanx, Paul

> [   43.478837] stack backtrace:
> [   43.478842] Pid: 4017, comm: NetworkManager Not tainted 2.6.35-rc2-git1 #8
> [   43.478846] Call Trace:
> [   43.478849]  <IRQ>  [<ffffffff81064e9c>] lockdep_rcu_dereference+0x9d/0xa5
> [   43.478876]  [<ffffffffa010cb3c>] sta_info_get_bss+0x71/0x12d [mac80211]
> [   43.478889]  [<ffffffffa010cc0d>] ieee80211_find_sta+0x15/0x2f [mac80211]
> [   43.478902]  [<ffffffffa019ae16>] iwlagn_tx_queue_reclaim+0xe7/0x1bb [iwlagn]
> [   43.478909]  [<ffffffff8106530b>] ? mark_lock+0x2d/0x262
> [   43.478920]  [<ffffffffa019e270>] iwlagn_rx_reply_tx+0x4cd/0x58a [iwlagn]
> [   43.478928]  [<ffffffff811ca313>] ? is_swiotlb_buffer+0x2e/0x3b
> [   43.478937]  [<ffffffffa0192ec2>] iwl_rx_handle+0x161/0x2bf [iwlagn]
> [   43.478946]  [<ffffffffa019370a>] iwl_irq_tasklet+0x2eb/0x408 [iwlagn]
> [   43.478953]  [<ffffffff8103f892>] tasklet_action+0xa7/0x10f
> [   43.478960]  [<ffffffff810404cf>] __do_softirq+0x148/0x25a
> [   43.478966]  [<ffffffff8100314c>] call_softirq+0x1c/0x28
> [   43.478972]  [<ffffffff81004d20>] do_softirq+0x38/0x80
> [   43.478977]  [<ffffffff8103ffd0>] irq_exit+0x45/0x94
> [   43.478983]  [<ffffffff81004465>] do_IRQ+0xad/0xc4
> [   43.478989]  [<ffffffff813ca3d3>] ret_from_intr+0x0/0xf
> [   43.478993]  <EOI>
