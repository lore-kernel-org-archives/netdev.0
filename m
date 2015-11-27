From: Sasha Levin <sasha.levin@oracle.com>
Subject: gigaset: freeing an active object
Date: Fri, 27 Nov 2015 10:19:03 -0500
Message-ID: <56587467.8050102@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tilman@imap.cc,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: pebolle@tiscali.nl, isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29012 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbbK0PT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 10:19:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Fuzzing with syzkaller on the latest -next kernel produced this error:

[  413.536749] WARNING: CPU: 6 PID: 25400 at lib/debugobjects.c:263 debug_print_object+0x1c4/0x1e0()
[  413.538111] ODEBUG: free active (active state 0) object type: timer_list hint: delayed_work_timer_fn+0x0/0x90
[  413.539598] Modules linked in:3470693efef57268844f02f5de3ab392d8cf5e209671ddd87163cb964c510659
[  413.540448] CPU: 6 PID: 25400 Comm: syzkaller_execu Not tainted 4.4.0-rc2-next-20151126-sasha-00005-g00d303e-dirty #2653
[  413.547614] Call Trace:
[  413.548077]  [<ffffffffa8e6b5bb>] dump_stack+0x72/0xb7
[  413.548765]  [<ffffffffa73531d3>] warn_slowpath_common+0x113/0x140
[  413.551151]  [<ffffffffa73532cb>] warn_slowpath_fmt+0xcb/0x100
[  413.554295]  [<ffffffffa8ed0194>] debug_print_object+0x1c4/0x1e0
[  413.556592]  [<ffffffffa8ed1035>] __debug_check_no_obj_freed+0x215/0x7a0
[  413.560526]  [<ffffffffa8ed2b6c>] debug_check_no_obj_freed+0x2c/0x40
[  413.561328]  [<ffffffffa77aac4c>] kfree+0x1fc/0x2f0
[  413.561970]  [<ffffffffae74b021>] gigaset_freecshw+0xe1/0x120
[  413.562723]  [<ffffffffae70669d>] gigaset_freecs+0x2ad/0x600
[  413.564240]  [<ffffffffae74ba60>] gigaset_tty_close+0x210/0x280
[  413.565774]  [<ffffffffa95ba6f2>] tty_ldisc_close.isra.1+0xc2/0xd0
[  413.566550]  [<ffffffffa95ba81b>] tty_ldisc_kill+0x4b/0x170
[  413.567253]  [<ffffffffa95bbba3>] tty_ldisc_release+0x183/0x240
[  413.568000]  [<ffffffffa95a507c>] tty_release+0xd1c/0xe80
[  413.570176]  [<ffffffffa78182fa>] __fput+0x32a/0x680
[  413.570888]  [<ffffffffa78186da>] ____fput+0x1a/0x20
[  413.571565]  [<ffffffffa73adf5c>] task_work_run+0x19c/0x1e0
[  413.572290]  [<ffffffffa735cae7>] do_exit+0xdf7/0x28f0
[  413.576188]  [<ffffffffa735e805>] do_group_exit+0x1b5/0x300
[  413.576905]  [<ffffffffa7382222>] get_signal+0x1182/0x1360
[  413.577627]  [<ffffffffa717b553>] do_signal+0x93/0x1690
[  413.584630]  [<ffffffffa70063b0>] exit_to_usermode_loop+0xc0/0x1e0
[  413.585412]  [<ffffffffa7007feb>] prepare_exit_to_usermode+0x10b/0x140
[  413.586187]  [<ffffffffb0a12c3e>] retint_user+0x8/0x23


Thanks,
Sasha
