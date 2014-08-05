From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [setsockopt] WARNING: CPU: 0 PID: 1444 at kernel/sched/core.c:7088
 __might_sleep+0x51/0x16f()
Date: Wed, 6 Aug 2014 05:46:24 +0800
Message-ID: <20140805214624.GA9973@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, lkp@01.org
To: Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings,

Here is a microcode/load_module error triggered by debug check commit
64c2181bc433b17f04da8fe8592aa83cceac9606 ("sched: Debug nested sleeps"):

[main] Setsockopt(1 8 80d1000 4) on fd 21 [1:2:1]
[main] Setsockopt(1 2f 80d1000 4) on fd 22 [4:2:60]
[   14.027148] ------------[ cut here ]------------
[   14.027864] WARNING: CPU: 0 PID: 210 at kernel/sched/core.c:7088 __might_sleep+0x40/0x68()
[   14.029295] do not call blocking ops when !TASK_RUNNING; state=2 set at [<c144e379>] prepare_to_wait+0x35/0x56
[   14.030590] Modules linked in:
[   14.031136] CPU: 0 PID: 210 Comm: trinity-main Not tainted 3.16.0-02167-g254135e #972
[   14.032263]  00000000 c0f4de4c c0f4de24 c196630c c0f4de3c c142f01a c1447632 c0f1dbb0
[   14.033480]  00000002 b0066140 c0f4de54 c142f057 00000009 c0f4de4c c1b3bac8 c0f4de68
[   14.034640]  c0f4de88 c1447632 c1b3bb12 00001bb0 c1b3bac8 00000002 c144e379 c144e379
[   14.035983] Call Trace:
[   14.036355]  [<c196630c>] dump_stack+0x16/0x18
[   14.037005]  [<c142f01a>] warn_slowpath_common+0x55/0x6c
[   14.037715]  [<c1447632>] ? __might_sleep+0x40/0x68
[   14.038372]  [<c142f057>] warn_slowpath_fmt+0x26/0x2a
[   14.039097]  [<c1447632>] __might_sleep+0x40/0x68
[   14.039787]  [<c144e379>] ? prepare_to_wait+0x35/0x56
[   14.040595]  [<c144e379>] ? prepare_to_wait+0x35/0x56
[   14.041272]  [<c14a837e>] kmem_cache_alloc+0x39/0xb0
[   14.041934]  [<c18fa2de>] ? __alloc_skb+0x3c/0x154
[   14.042572]  [<c18fa2de>] __alloc_skb+0x3c/0x154
[   14.043339]  [<c145117a>] ? mark_held_locks+0x44/0x60
[   14.044141]  [<c1946093>] sigd_enq2+0x2a/0xff
[   14.044836]  [<c1946188>] sigd_enq+0x20/0x2a
[   14.045405]  [<c19467fb>] svc_listen+0x8b/0x11f
[   14.046009]  [<c144e5a6>] ? __wake_up_sync+0xd/0xd
[   14.046653]  [<c18f4132>] SyS_listen+0x37/0x51
[   14.047423]  [<c18f4ce5>] SyS_socketcall+0x90/0x1c0
[   14.048328]  [<c145136e>] ? trace_hardirqs_on+0xb/0xd
[   14.049061]  [<c19729f6>] ? restore_all+0xf/0xf
[   14.049665]  [<c19729bd>] syscall_call+0x7/0x7
[   14.050253]  [<c1970000>] ? __ww_mutex_lock_interruptible+0x165/0x573
[   14.051147] ---[ end trace 6f1365c63eafedde ]---
[main] Setsockopt(1 2d 80d1000 f0) on fd 25 [1:1:1]

Thanks,
Fengguang
