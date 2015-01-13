From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [3.19-rc3] tg3: BUG: sleeping function called from invalid
 context
Date: Mon, 12 Jan 2015 18:30:55 -0800
Message-ID: <1421116255.16485.14.camel@prashant>
References: <54B46DD5.9050802@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54B46DD5.9050802@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-12 at 19:59 -0500, Peter Hurley wrote:
> On 3.19-rc3, I'm seeing this might_sleep() warning [1] from the tg3_open()
> call stack. Let me know if I need to bisect this.
> 
> Regards,
> Peter Hurley
> 
> [1]
> 
> [   17.203009] BUG: sleeping function called from invalid context at /home/peter/src/kernels/mainline/kernel/irq/manage.c:104
> [   17.203067] in_atomic(): 1, irqs_disabled(): 0, pid: 1106, name: ip
> [   17.203092] 2 locks held by ip/1106:
> [   17.205255]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff816adf1f>] rtnetlink_rcv+0x1f/0x40
> [   17.207445]  #1:  (&(&tp->lock)->rlock){+.....}, at: [<ffffffffa01073e6>] tg3_start+0xc06/0x11f0 [tg3]
> [   17.209725] CPU: 2 PID: 1106 Comm: ip Not tainted 3.19.0-rc3+wip-xeon+lockdep #rc3+wip
> [   17.211900] Hardware name: Dell Inc. Precision WorkStation T5400  /0RW203, BIOS A11 04/30/2012
> [   17.214086]  0000000000000068 ffff8802ac823498 ffffffff817af7e8 0000000000000005
> [   17.216265]  ffffffff81a9be78 ffff8802ac8234a8 ffffffff810998a5 ffff8802ac8234d8
> [   17.218446]  ffffffff8109991a ffff8802ac8234c8 ffff8802af0aae00 ffffffffa00ed000
> [   17.220636] Call Trace:
> [   17.222743]  [<ffffffff817af7e8>] dump_stack+0x4f/0x7b
> [   17.224808]  [<ffffffff810998a5>] ___might_sleep+0x105/0x140
> [   17.226842]  [<ffffffff8109991a>] __might_sleep+0x3a/0xa0
> [   17.228869]  [<ffffffffa00ed000>] ? 0xffffffffa00ed000
> [   17.230939]  [<ffffffff810d7d78>] synchronize_irq+0x38/0xa0
> [   17.232967]  [<ffffffffa00ed000>] ? 0xffffffffa00ed000
> [   17.234991]  [<ffffffffa010105f>] tg3_chip_reset+0x13f/0x9c0 [tg3]
> [   17.236988]  [<ffffffffa01020ae>] tg3_reset_hw+0x7e/0x2d20 [tg3]
> [   17.238996]  [<ffffffff813bfaff>] ? __udelay+0x2f/0x40
> [   17.241007]  [<ffffffffa00ef2f7>] ? _tw32_flush+0x47/0x80 [tg3]
> [   17.243066]  [<ffffffffa0104dac>] tg3_init_hw+0x5c/0x70 [tg3]
> [   17.245438]  [<ffffffffa010740b>] tg3_start+0xc2b/0x11f0 [tg3]
> [   17.247444]  [<ffffffffa0107ad7>] ? tg3_open+0x107/0x2e0 [tg3]
> [   17.249556]  [<ffffffff810c338d>] ? trace_hardirqs_on+0xd/0x10
> [   17.251581]  [<ffffffff8107806f>] ? __local_bh_enable_ip+0x6f/0x100
> [   17.253710]  [<ffffffffa0107af8>] tg3_open+0x128/0x2e0 [tg3]
> [   17.255758]  [<ffffffff816ba3f5>] ? netpoll_poll_disable+0x5/0xa0
> [   17.257932]  [<ffffffff816a14af>] __dev_open+0xbf/0x140
> [   17.260091]  [<ffffffff816a17c1>] __dev_change_flags+0xa1/0x160
> [   17.262222]  [<ffffffff816a18a9>] dev_change_flags+0x29/0x60
> [   17.264360]  [<ffffffff816b0e02>] do_setlink+0x2f2/0xa30
> [   17.266431]  [<ffffffff816b1b7f>] rtnl_newlink+0x51f/0x750
> [   17.268485]  [<ffffffff816b1749>] ? rtnl_newlink+0xe9/0x750
> [   17.270483]  [<ffffffff811869c2>] ? free_pages_prepare+0x1d2/0x270
> [   17.272507]  [<ffffffff810c32bd>] ? trace_hardirqs_on_caller+0x11d/0x1e0
> [   17.274531]  [<ffffffff813dd1b2>] ? nla_parse+0x32/0x120
> [   17.276531]  [<ffffffff81021ab5>] ? native_sched_clock+0x35/0xa0
> [   17.278514]  [<ffffffff816adfd5>] rtnetlink_rcv_msg+0x95/0x250
> [   17.280485]  [<ffffffff8109f699>] ? preempt_count_sub+0x49/0x50
> [   17.282448]  [<ffffffff817b4a02>] ? mutex_lock_nested+0x382/0x530
> [   17.284402]  [<ffffffff816adf1f>] ? rtnetlink_rcv+0x1f/0x40
> [   17.286290]  [<ffffffff816adf1f>] ? rtnetlink_rcv+0x1f/0x40
> [   17.288142]  [<ffffffff816adf40>] ? rtnetlink_rcv+0x40/0x40
> [   17.290031]  [<ffffffff816cedc1>] netlink_rcv_skb+0xc1/0xe0
> [   17.291836]  [<ffffffff816adf2e>] rtnetlink_rcv+0x2e/0x40
> [   17.293615]  [<ffffffff816ce473>] netlink_unicast+0xf3/0x1d0
> [   17.295420]  [<ffffffff816ce863>] netlink_sendmsg+0x313/0x690
> [   17.297132]  [<ffffffff811ada4f>] ? might_fault+0x5f/0xb0
> [   17.298799]  [<ffffffff8168253c>] do_sock_sendmsg+0x8c/0x100
> [   17.300493]  [<ffffffff81681e3e>] ? copy_msghdr_from_user+0x15e/0x1f0
> [   17.302173]  [<ffffffff81682aeb>] ___sys_sendmsg+0x30b/0x320
> [   17.303798]  [<ffffffff81021ab5>] ? native_sched_clock+0x35/0xa0
> [   17.305431]  [<ffffffff810bdee0>] ? cpuacct_account_field+0x80/0xb0
> [   17.307085]  [<ffffffff81021ab5>] ? native_sched_clock+0x35/0xa0
> [   17.308744]  [<ffffffff810a4f35>] ? sched_clock_local+0x25/0x90
> [   17.310375]  [<ffffffff810a5dc1>] ? vtime_account_user+0x91/0xa0
> [   17.311948]  [<ffffffff810a5198>] ? sched_clock_cpu+0xb8/0xe0
> [   17.313509]  [<ffffffff810bf8be>] ? put_lock_stats.isra.26+0xe/0x30
> [   17.315069]  [<ffffffff810c007e>] ? lock_release_holdtime.part.27+0x12e/0x1b0
> [   17.316618]  [<ffffffff810a5dc1>] ? vtime_account_user+0x91/0xa0
> [   17.318162]  [<ffffffff8109f5d1>] ? get_parent_ip+0x11/0x50
> [   17.319703]  [<ffffffff8109f699>] ? preempt_count_sub+0x49/0x50
> [   17.321235]  [<ffffffff811807e5>] ? context_tracking_user_exit+0x55/0x130
> [   17.322732]  [<ffffffff811807e5>] ? context_tracking_user_exit+0x55/0x130
> [   17.324197]  [<ffffffff816834f2>] __sys_sendmsg+0x42/0x80
> [   17.325634]  [<ffffffff81683542>] SyS_sendmsg+0x12/0x20
> [   17.327048]  [<ffffffff817ba12d>] system_call_fastpath+0x16/0x1b

Please bisect, there hasn't been tg3 code changes in this path that
might cause this. It would help to know the commit changes that is
triggering the problem. Also could you provide the device details, from
syslog look for "Tigon3 [partno(BCMxxxxx) rev xxxxxxx]". Thanks.
