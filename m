From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Sun, 25 Apr 2010 09:45:34 +0200
Message-ID: <1272181534.3614.1.camel@jlt3.sipsolutions.net>
References: <1271766716.2972.16.camel@dhcp231-113.rdu.redhat.com>
	 <j2ya44ae5cd1004200545q6be4ec82o18ae99d93e8c29c7@mail.gmail.com>
	 <20100420135227.GC2628@linux.vnet.ibm.com>
	 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
	 <20100421213543.GO2563@linux.vnet.ibm.com>
	 <20100422145640.GB3228@redhat.com>
	 <20100422160144.GC2524@linux.vnet.ibm.com>
	 <h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
	 <20100423194255.GE2589@linux.vnet.ibm.com>
	 <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
	 <20100425023455.GM2440@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Miles Lane <miles.lane@gmail.com>, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:52776 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab0DYHqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 03:46:25 -0400
In-Reply-To: <20100425023455.GM2440@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-04-24 at 19:34 -0700, Paul E. McKenney wrote:

> > [   51.912282] [ INFO: suspicious rcu_dereference_check() usage. ]
> > [   51.912285] ---------------------------------------------------
> > [   51.912289] net/mac80211/sta_info.c:886 invoked
> > rcu_dereference_check() without protection!
> > [   51.912293]
> > [   51.912293] other info that might help us debug this:
> > [   51.912295]
> > [   51.912298]
> > [   51.912298] rcu_scheduler_active = 1, debug_locks = 1
> > [   51.912302] no locks held by wpa_supplicant/3951.
> > [   51.912305]
> > [   51.912306] stack backtrace:
> > [   51.912310] Pid: 3951, comm: wpa_supplicant Not tainted 2.6.34-rc5-git3 #22
> > [   51.912314] Call Trace:
> > [   51.912317]  <IRQ>  [<ffffffff81067fbe>] lockdep_rcu_dereference+0x9d/0xa5
> > [   51.912345]  [<ffffffffa014f9ae>]
> > ieee80211_find_sta_by_hw+0x46/0x10f [mac80211]
> > [   51.912358]  [<ffffffffa014fa8e>] ieee80211_find_sta+0x17/0x19 [mac80211]
> > [   51.912373]  [<ffffffffa01e50f2>] iwl_tx_queue_reclaim+0xdb/0x1b1 [iwlcore]
> > [   51.912380]  [<ffffffff8106842b>] ? mark_lock+0x2d/0x235
> > [   51.912391]  [<ffffffffa0252f1c>] iwl5000_rx_reply_tx+0x4a9/0x556 [iwlagn]
> > [   51.912399]  [<ffffffff8120a353>] ? is_swiotlb_buffer+0x2e/0x3b
> > [   51.912407]  [<ffffffffa024bbf4>] iwl_rx_handle+0x163/0x2b5 [iwlagn]
> > [   51.912414]  [<ffffffff81068904>] ? trace_hardirqs_on_caller+0xfa/0x13f
> > [   51.912422]  [<ffffffffa024c3ac>] iwl_irq_tasklet+0x2bb/0x3c0 [iwlagn]
> > [   51.912429]  [<ffffffff810411f3>] tasklet_action+0xa7/0x10f
> > [   51.912435]  [<ffffffff81042205>] __do_softirq+0x144/0x252
> > [   51.912442]  [<ffffffff81003a8c>] call_softirq+0x1c/0x34
> > [   51.912447]  [<ffffffff810050e4>] do_softirq+0x38/0x80
> > [   51.912452]  [<ffffffff81041cd2>] irq_exit+0x45/0x94
> > [   51.912457]  [<ffffffff81004829>] do_IRQ+0xad/0xc4
> > [   51.912463]  [<ffffffff810cbbd3>] ? might_fault+0x63/0xb3
> > [   51.912470]  [<ffffffff813cfb93>] ret_from_intr+0x0/0xf
> > [   51.912474]  <EOI>  [<ffffffff810cbbd3>] ? might_fault+0x63/0xb3
> > [   51.912484]  [<ffffffff8106a75d>] ? lock_release+0x208/0x215
> > [   51.912490]  [<ffffffff810cbc1c>] might_fault+0xac/0xb3
> > [   51.912495]  [<ffffffff810cbbd3>] ? might_fault+0x63/0xb3
> > [   51.912501]  [<ffffffff812025e3>] __clear_user+0x15/0x59
> > [   51.912508]  [<ffffffff8100b2bc>] save_i387_xstate+0x9c/0x1bc
> > [   51.912515]  [<ffffffff81002276>] do_signal+0x240/0x686
> > [   51.912521]  [<ffffffff81002b9c>] ? sysret_check+0x27/0x62
> > [   51.912527]  [<ffffffff8106891e>] ? trace_hardirqs_on_caller+0x114/0x13f
> > [   51.912533]  [<ffffffff813cec80>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> > [   51.912539]  [<ffffffff810026e3>] do_notify_resume+0x27/0x5f
> > [   51.912545]  [<ffffffff813cec80>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> > [   51.912551]  [<ffffffff81002e86>] int_signal+0x12/0x17
> 
> This is a repeat from last time that confused me at the time.  I could
> do a hacky "fix" by putting an RCU read-side critical section around
> the for_each_sta_info() in ieee80211_find_sta_by_hw(), but I do not
> understand this code well enough to feel comfortable doing so.
> 
> Johannes, any enlightenment?

The station locking is a tad confusing, but I've added the right
annotations already, should be coming to a kernel near you soon (i.e.
are in net-2.6 right now).

johannes

