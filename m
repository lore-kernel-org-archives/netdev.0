From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.34-rc5-git6 (plus all patches) -- new INFO: suspicious
 rcu_dereference_check() usage.
Date: Mon, 26 Apr 2010 09:10:44 -0700
Message-ID: <20100426161044.GE2529@linux.vnet.ibm.com>
References: <s2ka44ae5cd1004251419hb8f4c137md0e399c464d9290a@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <s2ka44ae5cd1004251419hb8f4c137md0e399c464d9290a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 25, 2010 at 05:19:38PM -0400, Miles Lane wrote:
> [  139.730133] [ INFO: suspicious rcu_dereference_check() usage. ]
> [  139.730136] ---------------------------------------------------
> [  139.730139] include/net/inet_timewait_sock.h:227 invoked
> rcu_dereference_check() without protection!
> [  139.730142]
> [  139.730143] other info that might help us debug this:
> [  139.730144]
> [  139.730147]
> [  139.730148] rcu_scheduler_active = 1, debug_locks = 1
> [  139.730151] 1 lock held by swapper/0:
> [  139.730158]  #0:  (net/ipv4/tcp_minisocks.c:41){+.-...}, at:
> [<ffffffff81046ad2>] run_timer_softirq+0x19f/0x370
> [  139.730169]
> [  139.730170] stack backtrace:
> [  139.730173] Pid: 0, comm: swapper Not tainted 2.6.34-rc5-git6 #28
> [  139.730176] Call Trace:
> [  139.730178]  <IRQ>  [<ffffffff81065f9a>] lockdep_rcu_dereference+0x9d/0xa5
> [  139.730189]  [<ffffffff813d1abf>] twsk_net+0x4f/0x57
> [  139.730193]  [<ffffffff813d2122>] __inet_twsk_kill+0x79/0xd0
> [  139.730198]  [<ffffffff813d24f9>] inet_twdr_do_twkill_work+0x59/0xba
> [  139.730203]  [<ffffffff813d263d>] inet_twdr_hangman+0x30/0x97
> [  139.730207]  [<ffffffff81046b9e>] run_timer_softirq+0x26b/0x370
> [  139.730211]  [<ffffffff81046ad2>] ? run_timer_softirq+0x19f/0x370
> [  139.730216]  [<ffffffff813d260d>] ? inet_twdr_hangman+0x0/0x97
> [  139.730221]  [<ffffffff81040230>] ? __do_softirq+0x7f/0x252
> [  139.730225]  [<ffffffff810402f5>] __do_softirq+0x144/0x252
> [  139.730230]  [<ffffffff8100320c>] call_softirq+0x1c/0x34
> [  139.730235]  [<ffffffff81004864>] do_softirq+0x38/0x80
> [  139.730239]  [<ffffffff8103fdc2>] irq_exit+0x45/0x94
> [  139.730243]  [<ffffffff81003fa9>] do_IRQ+0xad/0xc4
> [  139.730247]  [<ffffffff81432953>] ret_from_intr+0x0/0xf
> [  139.730250]  <EOI>  [<ffffffff81248383>] ? acpi_idle_enter_bm+0x262/0x28d
> [  139.730260]  [<ffffffff81248379>] ? acpi_idle_enter_bm+0x258/0x28d
> [  139.730266]  [<ffffffff8137b9cf>] cpuidle_idle_call+0x9c/0x13d
> [  139.730273]  [<ffffffff810012c2>] cpu_idle+0xa5/0xfc
> [  139.730277]  [<ffffffff8142abdd>] start_secondary+0x1f3/0x1fc

This appears to be another symptom of the bug you located in your earlier
testing, so either Eric Biederman sends a patch or I improvise.

And thank you again for all your testing, Miles!!!

							Thanx, Paul
