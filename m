From: Ingo Molnar <mingo@elte.hu>
Subject: tip: origin tree boot crash (in the new micrel phy driver)
Date: Thu, 6 May 2010 11:59:40 +0200
Message-ID: <20100506095940.GA12711@elte.hu>
References: <20100505.012750.246538504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David J. Choi" <david.choi@micrel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100505.012750.246538504.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

>       drivers/net/phy: micrel phy driver

FYI, -tip testing started triggering this boot crash today (x86, 64-bit):

bus: 'mdio_bus': add driver STe101p
initcall ste10Xp_init+0x0/0x22 returned 0 after 52 usecs
calling  ksphy_init+0x0/0x5e @ 1
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff813b1e98>] strcmp+0x6/0x21
PGD 0
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
last sysfs file:
CPU 1
Pid: 1, comm: swapper Not tainted 2.6.34-rc5 #3328 A8N-E/System Product
Name
RIP: 0010:[<ffffffff813b1e98>]  [<ffffffff813b1e98>] strcmp+0x6/0x21
RSP: 0018:ffff88003f33fe00  EFLAGS: 00010286
Call Trace:
 [<ffffffff813ae59d>] kset_find_obj+0x3d/0x81
 [<ffffffff814e664f>] driver_find+0x1f/0x32
 [<ffffffff814e6732>] driver_register+0x64/0x103
 [<ffffffff83ca853f>] ? ksphy_init+0x0/0x5e
 [<ffffffff816adcf1>] phy_driver_register+0x3e/0x92
 [<ffffffff83ca853f>] ? ksphy_init+0x0/0x5e
 [<ffffffff83ca8553>] ksphy_init+0x14/0x5e
 [<ffffffff810001f9>] do_one_initcall+0x5e/0x15e
 [<ffffffff83c706bb>] kernel_init+0x17d/0x206
 [<ffffffff81002f24>] kernel_thread_helper+0x4/0x10
 [<ffffffff81d8d450>] ? restore_args+0x0/0x30
 [<ffffffff83c7053e>] ? kernel_init+0x0/0x206
 [<ffffffff81002f20>] ? kernel_thread_helper+0x0/0x10
Code: c1 80 39 00 75 f8 eb 0d 48 ff c1 48 ff ca 75 05 c6 01 00 eb 0e 40 8a 3e 48 ff c6 40 84 ff 40 88 39 75 e5 c9 c3 55 48 89 e5 8a 07 <8a> 16 48 ff c7 48 ff c6 38 d0 74 07 19 c0 83 c8 01 eb 06 84 c0
RIP  [<ffffffff813b1e98>] strcmp+0x6/0x21
 RSP <ffff88003f33fe00>
CR2: 0000000000000000
---[ end trace 73aaba243cb4fa42 ]---

I bisected it back to the following commit:

d05070091849015f8c5b7d55cd75b86ebb61b3ec is the first bad commit
commit d05070091849015f8c5b7d55cd75b86ebb61b3ec
Author: David J. Choi <david.choi@micrel.com>
Date:   Thu Apr 29 06:12:41 2010 +0000

    drivers/net/phy: micrel phy driver
    
    This is the first version of phy driver from Micrel Inc.
    
    Signed-off-by: David J. Choi <david.choi@micrel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

the config had:

  CONFIG_MICREL_PHY=y

Disabling the driver fixes the crash.

Thanks,

	Ingo
