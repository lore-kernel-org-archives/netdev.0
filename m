From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
 rcu_dereference_check() without protection!
Date: Mon, 7 Jun 2010 17:19:29 -0700
Message-ID: <20100608001929.GF2387@linux.vnet.ibm.com>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
In-Reply-To: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 07, 2010 at 02:14:25PM -0400, Miles Lane wrote:
> Hi All,
>=20
> I just reproduced a warning I reported quite a while ago.=A0 Is a pat=
ch
> for this in the pipeline?

I proposed a patch, thinking that it was a false positive.  Peter Zijls=
tra
pointed out that there was a real race, and proposed an alternative pat=
ch,
which may be found at http://lkml.org/lkml/2010/4/22/603.

Could you please test Peter's patch and let us know if it cures the pro=
blem?

							Thanx, Paul

> [=A0=A0=A0 0.167267] [ INFO: suspicious rcu_dereference_check() usage=
=2E ]
> [=A0=A0=A0 0.167396] ------------------------------------------------=
---
> [=A0=A0=A0 0.167526] include/linux/cgroup.h:534 invoked
> rcu_dereference_check() without protection!
> [=A0=A0=A0 0.167728]
> [=A0=A0=A0 0.167729] other info that might help us debug this:
> [=A0=A0=A0 0.167731]
> [=A0=A0=A0 0.168092]
> [=A0=A0=A0 0.168093] rcu_scheduler_active =3D 1, debug_locks =3D 1
> [=A0=A0=A0 0.168337] no locks held by watchdog/0/5.
> [=A0=A0=A0 0.168462]
> [=A0=A0=A0 0.168463] stack backtrace:
> [=A0=A0=A0 0.168704] Pid: 5, comm: watchdog/0 Not tainted 2.6.35-rc2-=
git1 #8
> [=A0=A0=A0 0.168834] Call Trace:
> [=A0=A0=A0 0.168965]=A0 [<ffffffff81064e9c>] lockdep_rcu_dereference+=
0x9d/0xa5
> [=A0=A0=A0 0.169100]=A0 [<ffffffff8102c1ce>] task_subsys_state+0x59/0=
x70
> [=A0=A0=A0 0.169232]=A0 [<ffffffff8103189b>] __sched_setscheduler+0x1=
9d/0x2f8
> [=A0=A0=A0 0.169365]=A0 [<ffffffff8102a5ef>] ? need_resched+0x1e/0x28
> [=A0=A0=A0 0.169497]=A0 [<ffffffff813c7d01>] ? schedule+0x586/0x619
> [=A0=A0=A0 0.169628]=A0 [<ffffffff81081c33>] ? watchdog+0x0/0x8c
> [=A0=A0=A0 0.169758]=A0 [<ffffffff81031a11>] sched_setscheduler+0xe/0=
x10
> [=A0=A0=A0 0.169889]=A0 [<ffffffff81081c5d>] watchdog+0x2a/0x8c
> [=A0=A0=A0 0.170010]=A0 [<ffffffff81081c33>] ? watchdog+0x0/0x8c
> [=A0=A0=A0 0.170141]=A0 [<ffffffff81054a82>] kthread+0x89/0x91
> [=A0=A0=A0 0.170274]=A0 [<ffffffff81003054>] kernel_thread_helper+0x4=
/0x10
> [=A0=A0=A0 0.170405]=A0 [<ffffffff813ca480>] ? restore_args+0x0/0x30
> [=A0=A0=A0 0.170536]=A0 [<ffffffff810549f9>] ? kthread+0x0/0x91
> [=A0=A0=A0 0.170667]=A0 [<ffffffff81003050>] ? kernel_thread_helper+0=
x0/0x10
> [    0.176751] lockdep: fixing up alternatives.
