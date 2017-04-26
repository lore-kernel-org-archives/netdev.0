From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 0/3] net: fix a stack out-of-bound access
Date: Tue, 25 Apr 2017 22:03:20 -0700
Message-ID: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33955 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2993372AbdDZFDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 01:03:36 -0400
Received: by mail-pg0-f68.google.com with SMTP id t7so11529986pgt.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 22:03:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes the following kernel bug reported by Andrey:

 BUG: KASAN: stack-out-of-bounds in bond_enslave+0xe0a/0x4ef0 at addr
 ffff8800666b7792
 Write of size 16 by task a.out/3894
 page:ffffea000199adc0 count:0 mapcount:0 mapping:          (null) index:0x0
 flags: 0x100000000000000()
 raw: 0100000000000000 0000000000000000 0000000000000000 00000000ffffffff
 raw: 0000000000000000 ffffea000199ade0 0000000000000000 0000000000000000
 page dumped because: kasan: bad access detected
 CPU: 1 PID: 3894 Comm: a.out Not tainted 4.11.0-rc7+ #251
 Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 Call Trace:
  __dump_stack lib/dump_stack.c:16
  dump_stack+0x292/0x398 lib/dump_stack.c:52
  kasan_report_error mm/kasan/report.c:212
  kasan_report+0x4d8/0x510 mm/kasan/report.c:347
  check_memory_region_inline mm/kasan/kasan.c:326
  check_memory_region+0x139/0x190 mm/kasan/kasan.c:333
  memcpy+0x37/0x50 mm/kasan/kasan.c:369
  bond_enslave+0xe0a/0x4ef0 drivers/net/bonding/bond_main.c:1491
  bond_do_ioctl+0xb5d/0xec0 drivers/net/bonding/bond_main.c:3449
  dev_ifsioc+0x53f/0x9f0 net/core/dev_ioctl.c:338
  dev_ioctl+0x249/0x1160 net/core/dev_ioctl.c:532
  sock_do_ioctl+0x94/0xb0 net/socket.c:913
  sock_ioctl+0x28f/0x440 net/socket.c:1004
  vfs_ioctl fs/ioctl.c:45
  do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
  SYSC_ioctl fs/ioctl.c:700
  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:204
 RIP: 0033:0x7fc764b31b79
 RSP: 002b:00007ffc1d73aa58 EFLAGS: 00000206 ORIG_RAX: 0000000000000010
 RAX: ffffffffffffffda RBX: 00007ffc1d73abb0 RCX: 00007fc764b31b79
 RDX: 00000000209eafd8 RSI: 0000008000008990 RDI: 0000000000000003
 RBP: 00000000004004e0 R08: 0000000000000000 R09: 0000000000000000
 R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000000000
 R13: 00007ffc1d73abb0 R14: 0000000000000000 R15: 0000000000000000

Please see each patch for details.

Cong Wang (3):
  net: check mac address length for dev_set_mac_address()
  bonding: use a larger struct for mac address
  team: use a larger struct for mac address

 drivers/net/bonding/bond_alb.c     |  8 ++++----
 drivers/net/bonding/bond_main.c    | 17 +++++++++--------
 drivers/net/bonding/bonding_priv.h |  6 ++++++
 drivers/net/team/team.c            |  9 ++++++---
 include/linux/netdevice.h          |  2 +-
 net/core/dev.c                     | 10 +++++++---
 net/core/dev_ioctl.c               |  2 ++
 7 files changed, 35 insertions(+), 19 deletions(-)

-- 
2.5.5
