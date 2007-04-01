From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: r8169 null pointer dereference
Date: Sat, 31 Mar 2007 19:50:46 -0500
Message-ID: <20070331195046.1fdda7c2@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:35358 "EHLO
	imf18aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750833AbXDAAv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 20:51:27 -0400
Received: from ibm59aec.bellsouth.net ([74.227.55.223])
          by imf18aec.mail.bellsouth.net with ESMTP
          id <20070401005126.BQVG22939.imf18aec.mail.bellsouth.net@ibm59aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Sat, 31 Mar 2007 20:51:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois,

I get this on 2.6.21-rc5 and earlier kernels going back to at least
2.6.20-git14, both i386 and x86_64, dual-core AM2 and LGA775
motherboards, using two different RTL8169 PCI add-in cards.  Has anyone
else reported it?

Unable to handle kernel NULL pointer dereference at  
 [<ffffffff883b43e5>] :r8169:rtl8169_rx_interrupt+0x5d/0x529
PGD 1d6bb067 PUD 1d6b9067 PMD 0 
Oops: 0000 [1] SMP 
last sysfs file: /class/net/eth1/address
CPU 1 
Modules linked in: r8169 i915 drm w83627ehf hwmon i2c_isa eeprom nf_conntrack_nd
Pid: 2689, comm: ip Not tainted 2.6.20-1.3024.fc7 #1
RIP: 0010:[<ffffffff883b43e5>]  [<ffffffff883b43e5>] :r8169:rtl8169_rx_interrup9
RSP: 0018:ffff81003f73be10  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff81001d546000 RCX: ffffffff8020cb04
RDX: 0000000000000000 RSI: ffff81001d546900 RDI: ffff81001d546000
RBP: ffff81003f73be60 R08: 0000000000000001 R09: 0000000000000001
R10: 0000000000000001 R11: ffffffff80263d40 R12: ffff81001d546900
R13: 0000000000000000 R14: ffff81001d546900 R15: 00000000fffcb85d
FS:  00002aaaaaac6820(0000) GS:ffff81003f783d58(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 000000001d623000 CR4: 00000000000006e0
Process ip (pid: 2689, threadinfo ffff81001d65a000, task ffff81001d680080)
Stack:  ffff81001d6807d8 ffff81001d546000 000000001d680080 0000000000000040
 ffff81001d6807a0 ffff81001d546000 ffff81001d546000 ffff8100026281d0
 ffff81001d546900 00000000fffcb85d ffff81003f73bec0 ffffffff883b6a10
Call Trace:
 <IRQ>  [<ffffffff883b6a10>] :r8169:rtl8169_poll+0x45/0x203
 [<ffffffff8020cbba>] net_rx_action+0xb0/0x1cf
 [<ffffffff80292d0a>] run_timer_softirq+0x1d0/0x1db
 [<ffffffff883b4fa3>] :r8169:rtl8169_interrupt+0x0/0x207
 [<ffffffff80211ca6>] __do_softirq+0x5f/0xe3
 [<ffffffff8025d31c>] call_softirq+0x1c/0x28
 [<ffffffff8026be1b>] do_softirq+0x3d/0xab
 [<ffffffff80290089>] irq_exit+0x4e/0x50
 [<ffffffff8027612d>] smp_apic_timer_interrupt+0x48/0x5a
 [<ffffffff8025cdcb>] apic_timer_interrupt+0x6b/0x70
 <EOI>  [<ffffffff802bcd03>] request_irq+0xb/0x11f
 [<ffffffff802bcddb>] request_irq+0xe3/0x11f
 [<ffffffff883b544f>] :r8169:rtl8169_open+0x56/0x1d9
 [<ffffffff80410364>] dev_open+0x37/0x79
 [<ffffffff8040ea60>] dev_change_flags+0x5d/0x122
 [<ffffffff80443fc8>] devinet_ioctl+0x259/0x5e9
 [<ffffffff80444618>] inet_ioctl+0x71/0x8f
 [<ffffffff80406de8>] sock_ioctl+0x1db/0x1fc
 [<ffffffff802414e5>] do_ioctl+0x2a/0x77
 [<ffffffff80230bb1>] vfs_ioctl+0x260/0x27d
 [<ffffffff8024bc6e>] sys_ioctl+0x5f/0x82
 [<ffffffff8025c2b5>] tracesys+0xdc/0xe1


Code: 41 8b 5d 00 85 db 0f 88 f7 03 00 00 f7 c3 00 00 20 00 74 60 
RIP  [<ffffffff883b43e5>] :r8169:rtl8169_rx_interrupt+0x5d/0x529
 RSP <ffff81003f73be10>
CR2: 0000000000000000
Kernel panic - not syncing: Aiee, killing interrupt handler!
