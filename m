From: Chetan C R <chetancr123@gmail.com>
Subject: spin lock held between 2 process
Date: Wed, 29 Oct 2014 14:32:52 +0530
Message-ID: <CAJ8diHRu+L_kMMfTyPAz+cwTfeQXTOFWm-RBZQzFOp18kO70jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:55926 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755468AbaJ2JCw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 05:02:52 -0400
Received: by mail-qc0-f169.google.com with SMTP id i17so2018708qcy.14
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 02:02:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In 3.4 kernel facing this issue.


[58762.332116] PID: 23472, Name: wlanconfig
[58762.337490] Backtrace:
[58762.339926] [<c001256c>] (dump_backtrace+0x0/0x10c) from
[<c0012894>] (show_stack+0x18/0x1c)
[58762.348330] r6:36b4a597 r5:c0744258 r4:d7dc1600 r3:c07003c4
[58762.353984] [<c001287c>] (show_stack+0x0/0x1c) from [<c0046828>]
(wdog_handler+0x16c/0x1b4)
[58762.362763] [<c00466bc>] (wdog_handler+0x0/0x1b4) from [<c00a0af0>]
(handle_percpu_devid_irq+0x88/0xa8)
[58762.372572] [<c00a0a68>] (handle_percpu_devid_irq+0x0/0xa8) from
[<c009d234>] (generic_handle_irq+0x34/0x48)
[58762.382382] r8:00000000 r7:c0741df0 r6:c0700f20 r5:00000014 r4:d2630=
000
[58762.388880] r3:c00a0a68
[58762.391473] [<c009d200>] (generic_handle_irq+0x0/0x48) from
[<c000f6d8>] (handle_IRQ+0x84/0xb0)
[58762.400157] [<c000f654>] (handle_IRQ+0x0/0xb0) from [<c000861c>]
(gic_handle_irq+0x70/0xc4)
[58762.408499] r8:d2631be8 r7:fa003000 r6:00000014 r5:c07410e4 r4:00000=
014
[58762.414997] r3:00000004
[58762.417621] [<c00085ac>] (gic_handle_irq+0x0/0xc4) from
[<c000ea00>] (__irq_svc+0x40/0x70)
[58762.425868] Exception stack(0xd2631be8 to 0xd2631c30)
[58762.430898] 1be0: c07f1430 0000c5db 00000001 00000000 c5dac5dc d8608=
40c
[58762.439052] 1c00: d792c000 d7557800 d7557800 d2630000 d8608400
d2631c44 20000013 d2631c34
[58762.447205] 1c20: c0123228 c03614f4 60000013 ffffffff
[58762.452266] [<c0361498>] (_raw_spin_lock+0x0/0x9c) from
[<c0123228>] (unregister_sysctl_table+0x64/0x7c)
[58762.461701] r4:d460f400
[58762.464231] [<c01231c4>] (unregister_sysctl_table+0x0/0x7c) from
[<c0347e9c>] (unregister_net_sysctl_table+0x10/0x14)
[58762.474822] r7:d7557800 r6:d7557800 r5:d860840c r4:d460f400
[58762.480476] [<c0347e8c>] (unregister_net_sysctl_table+0x0/0x14)
from [<c0317710>] (__devinet_sysctl_unregister+0x28/0x3c)
[58762.491410] [<c03176e8>] (__devinet_sysctl_unregister+0x0/0x3c)
from [<c0317c9c>] (inetdev_event+0x2e8/0x454)
[58762.501282] r4:00000000 r3:d7dc1600
[58762.504875] [<c03179b4>] (inetdev_event+0x0/0x454) from
[<c007aebc>] (notifier_call_chain+0x34/0x74)
[58762.513966] [<c007ae88>] (notifier_call_chain+0x0/0x74) from
[<c007afd0>] (raw_notifier_call_chain+0x20/0x28)
[58762.523869] r8:00200200 r7:c0824e40 r6:d2631d68 r5:d7557800 r4:00000=
006
[58762.530367] r3:ffffffff
[58762.532991] [<c007afb0>] (raw_notifier_call_chain+0x0/0x28) from
[<c02c2390>] (call_netdevice_notifiers+0x44/0x54)
[58762.543300] [<c02c234c>] (call_netdevice_notifiers+0x0/0x54) from
[<c02c2770>] (rollback_registered_many+0x1d0/0x2e0)
[58762.553891] r5:0000029e r4:d7557800
[58762.557452] [<c02c25a0>] (rollback_registered_many+0x0/0x2e0) from
[<c02c2918>] (rollback_registered+0x30/0x48)
[58762.567543] [<c02c28e8>] (rollback_registered+0x0/0x48) from
[<c02c4024>] (unregister_netdevice_queue+0x70/0xa0)
[58762.577821] [<c02c3fb4>] (unregister_netdevice_queue+0x0/0xa0) from
[<bf36a768>] (mac-driver_ioctl_delete_vap+0x188/0x1a0 [mac-driver])
[58762.588786] r5:d25b4000 r4:00000000
[58762.592504] [<bf36a5e0>] (mac-driver_ioctl_delete_vap+0x0/0x1a0
[mac-driver]) from [<bf361e88>] (ieee80211_ioctl+0x180/0x1400
[mac-driver])
[58762.603375] [<bf361d08>] (ieee80211_ioctl+0x0/0x1400 [mac-driver])
from [<c02c5d34>] (dev_ifsioc+0x314/0x334)
[58762.612654] [<c02c5a20>] (dev_ifsioc+0x0/0x334) from [<c02c64f8>]
(dev_ioctl+0x7a4/0x86c)
[58762.620839] r7:00000000 r6:c0824e40 r5:000089f8 r4:00000000
[58762.626462] [<c02c5d54>] (dev_ioctl+0x0/0x86c) from [<c02b0b88>]
(sock_ioctl+0x3c/0x288)
[58762.634553] [<c02b0b4c>] (sock_ioctl+0x0/0x288) from [<c00e8eb8>]
(do_vfs_ioctl+0x5a8/0x608)
[58762.642957] r6:be8900a8 r5:db248000 r4:d4f08aa0 r3:c02b0b4c
[58762.648611] [<c00e8910>] (do_vfs_ioctl+0x0/0x608) from [<c00e8f58>]
(sys_ioctl+0x40/0x64)
[58762.656765] r8:c000ef84 r7:db248000 r6:be8900a8 r5:000089f8 r4:00000=
003
[58762.663450] [<c00e8f18>] (sys_ioctl+0x0/0x64) from [<c000ee00>]
(ret_fast_syscall+0x0/0x30)
[58762.671791] r7:00000036 r6:00000003 r5:000089f8 r4:be8900a8

=E2=80=A6

[58763.810779] PID: 26771, Name: lua
[58763.815528] Backtrace: no frame pointer
[58763.819370] Kernel panic - not syncing:
[58763.825712] CPU1: stopping
[58763.828399] Backtrace:
[58763.830835] [<c001256c>] (dump_backtrace+0x0/0x10c) from
[<c0359d8c>] (dump_stack+0x18/0x1c)
[58763.839239] r6:d789a000 r5:c07410e4 r4:00000001 r3:c07003c4
[58763.844894] [<c0359d74>] (dump_stack+0x0/0x1c) from [<c00145b0>]
(handle_IPI+0x100/0x1c4)
[58763.853047] [<c00144b0>] (handle_IPI+0x0/0x1c4) from [<c0008664>]
(gic_handle_irq+0xb8/0xc4)
[58763.861451] [<c00085ac>] (gic_handle_irq+0x0/0xc4) from
[<c000ea00>] (__irq_svc+0x40/0x70)
[58763.869698] Exception stack(0xd789bcc0 to 0xd789bd08)
[58763.874728] bcc0: c07f1430 0000c5dc 00000001 00000000 c5dac5dd
ddb22890 00000081 ddb22890
[58763.882913] bce0: 00000000 d789a000 d789a000 d789bd1c 20000013
d789bd0c c0122a80 c03614f4
[58763.891067] bd00: 60000013 ffffffff
[58763.894534] [<c0361498>] (_raw_spin_lock+0x0/0x9c) from
[<c0122a80>] (sysctl_head_grab+0x20/0x4c)
[58763.903375] r4:c0767c54
[58763.905906] [<c0122a60>] (sysctl_head_grab+0x0/0x4c) from
[<c0122acc>] (grab_header+0x20/0x28)
[58763.914497] r4:ddb22890 r3:c0767c54
[58763.918058] [<c0122aac>] (grab_header+0x0/0x28) from [<c0123cb4>]
(proc_sys_permission+0x38/0x80)
[58763.926930] [<c0123c7c>] (proc_sys_permission+0x0/0x80) from
[<c00e399c>] (inode_permission+0x7c/0xc0)
[58763.936209] r6:00000081 r5:ddb22890 r4:d24fc00a r3:c0123c7c
[58763.941832] [<c00e3920>] (inode_permission+0x0/0xc0) from
[<c00e3f8c>] (link_path_walk+0x5c/0x7e0)
[58763.950767] r6:ddb22890 r5:d789be70 r4:d24fc00a r3:00000051
[58763.956421] [<c00e3f30>] (link_path_walk+0x0/0x7e0) from
[<c00e4cc0>] (path_lookupat+0x5c/0x6c4)
[58763.965200] [<c00e4c64>] (path_lookupat+0x0/0x6c4) from
[<c00e534c>] (do_path_lookup+0x24/0x60)
[58763.973884] [<c00e5328>] (do_path_lookup+0x0/0x60) from
[<c00e698c>] (user_path_at_empty+0x60/0x90)
[58763.982913] r7:ffffff9c r6:d789be70 r5:d24fc000 r4:00000001
[58763.988536] [<c00e692c>] (user_path_at_empty+0x0/0x90) from
[<c00e69d8>] (user_path_at+0x1c/0x24)
[58763.997408] r8:c000ef84 r7:000000c3 r6:00000000 r5:d789bf40 r4:beaf1=
cb8
[58764.004094] [<c00e69bc>] (user_path_at+0x0/0x24) from [<c00dd8b4>]
(vfs_fstatat+0x3c/0x6c)
[58764.012341] [<c00dd878>] (vfs_fstatat+0x0/0x6c) from [<c00dd930>]
(vfs_stat+0x24/0x28)
[58764.020214] r5:00e2f438 r4:beaf1cb8
[58764.023775] [<c00dd90c>] (vfs_stat+0x0/0x28) from [<c00ddb0c>]
(sys_stat64+0x1c/0x38)
[58764.031616] [<c00ddaf0>] (sys_stat64+0x0/0x38) from [<c000ee00>]
(ret_fast_syscall+0x0/0x30)

=46acing this look up issue in 3.4.0 kernel. Any pointers to resolve th=
is issue?

Thanks,
