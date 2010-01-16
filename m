From: "Nori, Sekhar" <nsekhar@ti.com>
Subject: phylib: kernel oops on resume with 2.6.33-rc4
Date: Sat, 16 Jan 2010 21:38:34 +0530
Message-ID: <B85A65D85D7EB246BE421B3FB0FBB59301E2025EA9@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "avorontsov@ru.mvista.com" <avorontsov@ru.mvista.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:60166 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255Ab0APQIv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 11:08:51 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello all,

I am hitting a kernel oops when resuming from suspend-to-RAM on 2.6.33-rc4
kernel.

The MAC is TI DaVinci EMAC and PHY is SMSC LAN8710. However, I also hit the
issue even when using generic PHY driver (CONFIG_SMSC_PHY turned off).

On reverting commit 541cd3e "phylib: Fix deadlock on resume" which was
introduced in 2.6.33-rc4, the issue doesn't come about. So far, I haven't
figured out how this particular commit is causing the oops. Full oops report
is attached. Appreciate any help in debugging this.

Thanks,
Sekhar

-----8<---------

root@da850-omapl138-evm:~# rtcwake -m mem -d /dev/rtc0 -s 15
wakeup from "mem" at Sat Jan  1 00:02:01 2000
PM: Syncing filesystems ... done.
Freezing user space processes ... (elapsed 0.01 seconds) done.
Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
Suspending console(s) (use no_console_suspend to debug)
PM: suspend of devices complete after 212.456 msecs
PM: late suspend of devices complete after 0.697 msecs
PM: early resume of devices complete after 0.220 msecs
eth0: attached PHY driver [SMSC LAN8710/LAN8720] (mii_bus:phy_addr=1:00, id=7c0f1)
PM: resume of devices complete after 237.098 msecs
Restarting tasks ... done.
kernel BUG at kernel/workqueue.c:354!
Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = c0004000
[00000000] *pgd=00000000
Internal error: Oops: 817 [#1] PREEMPT
last sysfs file: /sys/power/state
Modules linked in:
CPU: 0    Not tainted  (2.6.33-rc4 #1830)
PC is at __bug+0x20/0x2c
LR is at release_console_sem+0xf0/0xfc
pc : [<c002c5b8>]    lr : [<c003ed68>]    psr: 60000013
sp : c7833ef0  ip : c7833e30  fp : c7833efc
r10: 00000000  r9 : 00000000  r8 : c78dfb30
r7 : 00000000  r6 : 00000064  r5 : ffffffff  r4 : c78dfb04
r3 : 00000000  r2 : 00000000  r1 : 0000182b  r0 : 0000002c
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 0005317f  Table: c7b64000  DAC: 00000017
Process events/0 (pid: 4, stack limit = 0xc7832270)
Stack: (0xc7833ef0 to 0xc7834000)
3ee0:                                     c7833f1c c7833f00 c0052a54 c002c5a8
3f00: 00000000 c78dfb04 c78dfa00 00000000 c7833f2c c7833f20 c0052b30 c00529f0
3f20: c7833f3c c7833f30 c0052b58 c0052b14 c7833f64 c7833f40 c01cf8b4 c0052b44
3f40: c78dfb08 c7832000 c78dfb04 c7800380 c01cf4e0 00000000 c7833f8c c7833f68
3f60: c0052578 c01cf4f0 c7832000 c7800388 c7832000 c7800380 00000000 00000000
3f80: c7833fc4 c7833f90 c0052730 c00524c4 c02a6440 00000000 c7820960 c0056428
3fa0: c7833fa0 c7833fa0 c7833fcc c7823f18 c7800380 c005263c c7833ff4 c7833fc8
3fc0: c00560c0 c005264c 00000000 00000000 c7833fd0 c7833fd0 00000000 00000000
3fe0: 00000000 00000000 00000000 c7833ff8 c0042218 c0056048 44004012 00300000
Backtrace:
[<c002c598>] (__bug+0x0/0x2c) from [<c0052a54>] (queue_delayed_work_on+0x74/0xf8)
[<c00529e0>] (queue_delayed_work_on+0x0/0xf8) from [<c0052b30>] (queue_delayed_work+0x2c/0x30)
 r7:00000000 r6:c78dfa00 r5:c78dfb04 r4:00000000
[<c0052b04>] (queue_delayed_work+0x0/0x30) from [<c0052b58>] (schedule_delayed_work+0x24/0x2c)
[<c0052b34>] (schedule_delayed_work+0x0/0x2c) from [<c01cf8b4>] (phy_state_machine+0x3d4/0x3e8)
[<c01cf4e0>] (phy_state_machine+0x0/0x3e8) from [<c0052578>] (run_workqueue+0xc4/0x188)
 r9:00000000 r8:c01cf4e0 r7:c7800380 r6:c78dfb04 r5:c7832000
r4:c78dfb08
[<c00524b4>] (run_workqueue+0x0/0x188) from [<c0052730>] (worker_thread+0xf4/0x108)
 r9:00000000 r8:00000000 r7:c7800380 r6:c7832000 r5:c7800388
r4:c7832000
[<c005263c>] (worker_thread+0x0/0x108) from [<c00560c0>] (kthread+0x88/0x90)
 r7:c005263c r6:c7800380 r5:c7823f18 r4:c7833fcc
[<c0056038>] (kthread+0x0/0x90) from [<c0042218>] (do_exit+0x0/0x280)
 r7:00000000 r6:00000000 r5:00000000 r4:00000000
Code: e1a01000 e59f000c eb09e6f5 e3a03000 (e5833000)
---[ end trace e88b3bd0ec06cbd0 ]---
nfs: server 172.24.190.197 not responding, still trying

