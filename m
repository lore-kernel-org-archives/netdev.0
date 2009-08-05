From: Frans Pop <elendil@planet.nl>
Subject: BUG: spinlock bad magic on CPU#1, swapper/1
Date: Wed, 5 Aug 2009 11:36:44 +0200
Message-ID: <200908051136.44908.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml110.kpnxchange.com ([195.121.3.14]:55918 "EHLO
	CPSMTPM-EML110.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934010AbZHEJgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 05:36:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current v2.6.31-rc5-246-g90bc1a6 gives me:

BUG: spinlock bad magic on CPU#1, swapper/1
 lock: ffff88007e1889c8, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
Pid: 1, comm: swapper Not tainted 2.6.31-rc5 #4
Call Trace:
 [<ffffffff811345e8>] spin_bug+0xa2/0xaa
 [<ffffffff8113469e>] _raw_spin_lock+0x23/0x135
 [<ffffffff8125664e>] _spin_lock_bh+0x19/0x1e
 [<ffffffff811e3702>] alloc_netdev_mq+0x127/0x211
 [<ffffffff81433487>] ? netdev_init+0x6a/0xac
 [<ffffffff811a81eb>] ? loopback_setup+0x0/0x7b
 [<ffffffff8142e718>] loopback_net_init+0x30/0x7a
 [<ffffffff811dd62e>] register_pernet_device+0x2b/0x58
 [<ffffffff814336bd>] net_dev_init+0x13d/0x19b
 [<ffffffff81433580>] ? net_dev_init+0x0/0x19b
 [<ffffffff8100905c>] do_one_initcall+0x56/0x12b
 [<ffffffff8106f55b>] ? register_irq_proc+0xb0/0xcc
 [<ffffffff810e0000>] ? proc_pid_cmdline+0x5a/0xf9
 [<ffffffff8140f65d>] kernel_init+0x14d/0x1a3
 [<ffffffff8100ca7a>] child_rip+0xa/0x20
 [<ffffffff8140f510>] ? kernel_init+0x0/0x1a3
 [<ffffffff8100ca70>] ? child_rip+0x0/0x20

Error occurs during early boot (between PCI/ACPI init and PnP init).

.31-rc5 itself did not give that error.

Cheers,
FJP
