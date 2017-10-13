From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 197213] New: panic in interrupt after ioctl to tun
Date: Fri, 13 Oct 2017 08:11:17 -0700
Message-ID: <20171013081117.61e82817@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:48880 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753337AbdJMPLU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 11:11:20 -0400
Received: by mail-pf0-f170.google.com with SMTP id b79so10647226pfk.5
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 08:11:19 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id a70sm2893454pfa.94.2017.10.13.08.11.19
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Oct 2017 08:11:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 12 Oct 2017 19:17:13 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 197213] New: panic in interrupt after ioctl to tun


https://bugzilla.kernel.org/show_bug.cgi?id=197213

            Bug ID: 197213
           Summary: panic in interrupt after ioctl to tun
           Product: Networking
           Version: 2.5
    Kernel Version: 4.14.0-rc4
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: avekceeb@gmail.com
        Regression: No

Hi,

this is one more corner case found by syzkaller.
I'm not sure that 'Networking' is the right category for this, but the panic
was triggered by ioctl to /dev/net/tun...


[   13.728009] BUG: unable to handle kernel NULL pointer dereference at        
  (null)
[   13.728903] IP: run_timer_softirq+0x315/0x3f0
[   13.729401] PGD 7bd8b067 P4D 7bd8b067 PUD 7bd7f067 PMD 0 
[   13.730040] Oops: 0002 [#1] SMP
[   13.730400] Modules linked in:
[   13.730747] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.14.0-rc4-with-tun #1
[   13.731533] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.0.0-prebuilt.qemu-project.org 04/01/2014
[   13.732672] task: ffffffffa280f480 task.stack: ffffffffa2800000
[   13.733332] RIP: 0010:run_timer_softirq+0x315/0x3f0
[   13.733883] RSP: 0018:ffff961b7fc03ed0 EFLAGS: 00010086
[   13.734467] RAX: ffff961b7bf070c0 RBX: ffff961b7fc10cc0 RCX:
0000000000000000
[   13.735265] RDX: dead000000000200 RSI: 00000000fffffe01 RDI:
ffff961b7fc10cc0
[   13.736059] RBP: ffff961b7fc03f50 R08: 00000000fffba1c0 R09:
ffff961b7fc11168
[   13.736857] R10: ffff961b7fc03ee8 R11: ffff961b7fc10d30 R12:
ffff961b7fc03ee0
[   13.737652] R13: dead000000000200 R14: 0000000000000001 R15:
ffff961b7bf070c0
[   13.738463] FS:  0000000000000000(0000) GS:ffff961b7fc00000(0000)
knlGS:0000000000000000
[   13.739017] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   13.739339] CR2: 0000000000000000 CR3: 000000007bcf8000 CR4:
00000000000006f0
[   13.739741] Call Trace:
[   13.739882]  <IRQ>
[   13.740000]  ? ktime_get+0x3b/0x90
[   13.740196]  ? lapic_next_event+0x18/0x20
[   13.740413]  __do_softirq+0xcf/0x2a8
[   13.740606]  irq_exit+0xab/0xb0
[   13.740778]  smp_apic_timer_interrupt+0x64/0x110
[   13.741025]  apic_timer_interrupt+0x90/0xa0
[   13.741250]  </IRQ>
[   13.741367] RIP: 0010:default_idle+0x18/0xf0
[   13.741596] RSP: 0018:ffffffffa2803e60 EFLAGS: 00000246 ORIG_RAX:
ffffffffffffff10
[   13.741998] RAX: 0000000080000000 RBX: ffffffffa293f5e0 RCX:
0000000000000000
[   13.742370] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
0000000000000000
[   13.742750] RBP: ffffffffa2803e78 R08: 000000040a453dcd R09:
ffff9c324031f930
[   13.743128] R10: 0000000000000000 R11: 00000069d14f9aee R12:
0000000000000000
[   13.743504] R13: 0000000000000000 R14: ffffffffa2a37780 R15:
0000000000000000
[   13.743883]  arch_cpu_idle+0xa/0x10
[   13.744072]  default_idle_call+0x1e/0x30
[   13.744284]  do_idle+0x14f/0x1a0
[   13.744458]  cpu_startup_entry+0x18/0x20
[   13.744670]  rest_init+0xa9/0xb0
[   13.744845]  start_kernel+0x3c6/0x3d3
[   13.745043]  x86_64_start_reservations+0x24/0x26
[   13.745291]  x86_64_start_kernel+0x6f/0x72
[   13.745512]  secondary_startup_64+0xa5/0xa5
[   13.745741] Code: 88 4c 39 65 88 0f 84 3b ff ff ff 49 8b 04 24 48 85 c0 74
56 4d 8b 3c 24 4c 89 7b 08 0f 1f 44 00 00 49 8b 17 49 8b 4f 08 48 85 d2 <48> 89
11 74 04 48 89 4a 08 41 f6 47 2a 20 49 c7 47 08 00 00 00 
[   13.746745] RIP: run_timer_softirq+0x315/0x3f0 RSP: ffff961b7fc03ed0
[   13.747087] CR2: 0000000000000000
[   13.747270] ---[ end trace 04d492145975c7cc ]---
[   13.747516] Kernel panic - not syncing: Fatal exception in interrupt
[   13.747946] Kernel Offset: 0x20a00000 from 0xffffffff81000000 (relocation
range: 0xffffffff80000000-0xffffffffbfffffff)
[   13.748515] ---[ end Kernel panic - not syncing: Fatal exception in
interrupt

Reproducer:

#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>

char addr[40] = {0xcf, 0x0b, 0x0b, 0x99, 0x22, 0x33, 0x96, 0xdf, 0xbd, 0x2e,
0x29, 0x1b, 0x4d, 0xc0, 0x2a, 0xee, 0x03};

void test() {
    int fd = -1;
    fd = open("/dev/net/tun", 0, 0);
    syscall(__NR_ioctl, fd, 0x400454caul, addr);
}

#define max_iter 10
int main(void) {
        int iter;
        for (iter = 0; iter<max_iter; iter++) {
        test();
            printf("done %d of %d\n", iter+1, max_iter);
        }
    return 0;
}

Panic happens on variety of configs with CONFIG_TUN=y set from (at least) 4.12
to current stable (4.14-rc4)
virtual, bare metal - doesn't matter.

[  164.060173]
==================================================================
[  164.062769] BUG: KASAN: use-after-free in run_timer_softirq+0xd84/0x1000
[  164.065030] Write of size 8 at addr ffff880065557148 by task swapper/0/0
[  164.067264] 
[  164.067812] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.13.1-kcov-qemu-my #1
[  164.070192] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.10.1-1ubuntu1 04/01/2014
[  164.071510] Call Trace:
[  164.071751]  <IRQ>
[  164.071959]  dump_stack+0x83/0xb8
[  164.072281]  print_address_description+0x78/0x290
[  164.072732]  kasan_report+0x257/0x370
[  164.073088]  ? run_timer_softirq+0xd84/0x1000
[  164.073508]  __asan_report_store8_noabort+0x1c/0x20
[  164.073977]  run_timer_softirq+0xd84/0x1000
[  164.074380]  ? add_timer_on+0x630/0x630
[  164.074757]  ? native_apic_msr_write+0x2b/0x30
[  164.075185]  ? lapic_next_event+0x5f/0x90
[  164.075573]  ? clockevents_program_event+0x21d/0x2f0
[  164.076049]  ? tick_program_event+0x84/0xd0
[  164.076453]  __do_softirq+0x1c3/0x5a1
[  164.076809]  irq_exit+0x14e/0x180
[  164.077132]  smp_apic_timer_interrupt+0x7b/0xa0
[  164.077567]  apic_timer_interrupt+0x89/0x90
[  164.077969] RIP: 0010:native_safe_halt+0x6/0x10
[  164.078403] RSP: 0018:ffffffff83607d08 EFLAGS: 00000246 ORIG_RAX:
ffffffffffffff10
[  164.079123] RAX: 0000000000000000 RBX: ffffffff83616d40 RCX:
0100000000000000
[  164.079797] RDX: 1ffffffff06c2da8 RSI: 0000000000000000 RDI:
0000000000000000
[  164.080472] RBP: ffffffff83607d08 R08: ffff88007ff3501c R09:
ffff88007ff35008
[  164.081145] R10: ffff88007ff35018 R11: ffff88007ff35010 R12:
ffffffff83c5cba0
[  164.081820] R13: ffffffff83616d40 R14: 0000000000000000 R15:
ffffffff83616d40
[  164.082498]  </IRQ>
[  164.082719]  ? next_zone+0x48/0x60
[  164.083046]  default_idle+0x22/0x230
[  164.083390]  arch_cpu_idle+0xf/0x20
[  164.083725]  default_idle_call+0x3b/0x60
[  164.084101]  do_idle+0x23e/0x310
[  164.084413]  cpu_startup_entry+0xcb/0xe0
[  164.084789]  ? cpu_in_idle+0x20/0x20
[  164.085134]  rest_init+0xe8/0xf0
[  164.085447]  start_kernel+0x6bc/0x6f1
[  164.085784]  ? thread_stack_cache_init+0x10/0x10
[  164.086204]  ? early_idt_handler_array+0x120/0x120
[  164.086652]  x86_64_start_reservations+0x2a/0x2c
[  164.087003]  x86_64_start_kernel+0x152/0x175
[  164.087332]  secondary_startup_64+0x9f/0x9f
[  164.087647] 
[  164.087768] The buggy address belongs to the page:
[  164.088139] page:ffffea00019555c0 count:0 mapcount:0 mapping:         
(null) index:0x0
[  164.088733] flags: 0xfffffc0000000()
[  164.089008] raw: 000fffffc0000000 0000000000000000 0000000000000000
00000000ffffffff
[  164.089582] raw: dead000000000100 dead000000000200 0000000000000000
0000000000000000
[  164.090155] page dumped because: kasan: bad access detected
[  164.090568] 
[  164.090707] Memory state around the buggy address:
[  164.091066]  ffff880065557000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff
[  164.091598]  ffff880065557080: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff
[  164.092131] >ffff880065557100: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff
[  164.092663]                                               ^
[  164.093077]  ffff880065557180: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff
[  164.093608]  ffff880065557200: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff
[  164.094139]
==================================================================

-- 
You are receiving this mail because:
You are the assignee for the bug.
