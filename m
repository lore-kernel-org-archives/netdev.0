From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: rcu warnings in ip6fl_get_first
Date: Fri, 8 Feb 2013 01:37:29 +0000 (UTC)
Message-ID: <kf1ksp$699$1@ger.gmane.org>
References: <51140154.9040901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

["Followup-To:" header set to gmane.linux.network.]
On Thu, 07 Feb 2013 at 19:32 GMT, Sasha Levin <sasha.levin@oracle.com> wrote:
> Hi guys,
>
> I got the following while fuzzing with trinity inside a KVM tools guest:
>
> [   51.680236] ===============================
> [   51.681914] [ INFO: suspicious RCU usage. ]
> [   51.683610] 3.8.0-rc6-next-20130206-sasha-00028-g83214f7-dirty #276 Tainted: G        W
> [   51.686703] -------------------------------
> [   51.688281] net/ipv6/ip6_flowlabel.c:671 suspicious rcu_dereference_check() usage!
> [   51.691345]
> [   51.691345] other info that might help us debug this:
> [   51.691345]
> [   51.694479]
> [   51.694479] rcu_scheduler_active = 1, debug_locks = 1
> [   51.697650] 2 locks held by trinity/7421:
> [   51.701271]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff812b049a>] seq_read+0x3a/0x3d0
> [   51.704292]  #1:  (rcu_read_lock_bh){.+....}, at: [<ffffffff8397cde0>] ip6fl_seq_start+0x0/0xe0
> [   51.707845]
> [   51.707845] stack backtrace:
> [   51.709678] Pid: 7421, comm: trinity Tainted: G        W    3.8.0-rc6-next-20130206-sasha-00028-g83214f7-dirty #276
> [   51.713495] Call Trace:
> [   51.714370]  [<ffffffff81181fdb>] lockdep_rcu_suspicious+0x10b/0x120
> [   51.716560]  [<ffffffff8397caca>] ip6fl_get_first+0x8a/0x140
> [   51.718755]  [<ffffffff8397cdb7>] ip6fl_seq_next+0x17/0x40
> [   51.720963]  [<ffffffff812b0711>] seq_read+0x2b1/0x3d0
> [   51.723056]  [<ffffffff812b0460>] ? seq_lseek+0x110/0x110
> [   51.725238]  [<ffffffff812f9c0c>] proc_reg_read+0x9c/0xd0
> [   51.727266]  [<ffffffff812f9b70>] ? proc_reg_write+0xd0/0xd0
> [   51.729337]  [<ffffffff8128b2eb>] do_loop_readv_writev+0x4b/0x90
> [   51.731846]  [<ffffffff8128b566>] do_readv_writev+0xf6/0x1d0
> [   51.734092]  [<ffffffff8128b6de>] vfs_readv+0x3e/0x60
> [   51.736015]  [<ffffffff8128b750>] sys_readv+0x50/0xd0
> [   51.737930]  [<ffffffff83d73d98>] tracesys+0xe1/0xe6
>
> This is the result of commit "ipv6 flowlabel: Convert hash list to RCU." which
> mixes between regular and _bh() locking.
>
>
> Thanks,
> Sasha
