From: Andrew Morton <akpm@osdl.org>
Subject: Fw: BUG: atomic counter underflow when running "rmmod tg3" on
 2.6.10-rc1-mm3
Date: Mon, 8 Nov 2004 21:41:59 -0800
Message-ID: <20041108214159.6400e8de.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bernhard Rosenkraenzer <bero@arklinux.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


There's a debug patch in -mm which generates a trace when someone does
atomic_dec_and_test() on an atomic_t which already has a value of zero.

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.10-rc1/2.6.10-rc1-mm3/broken-out/detect-atomic-counter-underflows.patch

It looks like it has found a problem in qdisc_destroy().



Begin forwarded message:

Date: Tue, 9 Nov 2004 03:33:36 +0100
From: Bernhard Rosenkraenzer <bero@arklinux.org>
To: linux-kernel@vger.kernel.org
Subject: BUG: atomic counter underflow when running "rmmod tg3" on 2.6.10-rc1-mm3


BUG: atomic counter underflow at:
 [<c02882f6>] qdisc_destroy+0x66/0x80
 [<c02885e2>] dev_shutdown+0x32/0x90
 [<c02d796f>] __down_failed_trylock+0x7/0xc
 [<c027b6b2>] unregister_netdevice+0x142/0x29e
 [<c014c171>] handle_mm_fault+0xf1/0x510
 [<c0240a95>] unregister_netdev+0x15/0x20
 [<e0d3a2b5>] tg3_remove_one+0x25/0x70 [tg3]
 [<c01db4e9>] pci_device_remove+0x69/0x70
 [<c0232646>] device_release_driver+0x86/0x90
 [<c0232a2b>] bus_remove_driver+0x5b/0x100
 [<e0d3a780>] tg3_cleanup+0x0/0x13 [tg3]
 [<c0232fc0>] driver_unregister+0x10/0x20
 [<c01db234>] pci_unregister_driver+0x14/0xa0
 [<e0d3a78f>] tg3_cleanup+0xf/0x13 [tg3]
 [<c013462b>] sys_delete_module+0x17b/0x1e0
 [<c0104ff1>] sysenter_past_esp+0x52/0x71
divert: freeing divert_blk for eth0
