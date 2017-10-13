From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fw: [Bug 197213] New: panic in interrupt after ioctl to tun
Date: Fri, 13 Oct 2017 10:31:14 -0700
Message-ID: <CAM_iQpVHcx0m_kUJqAdoKpYz50SzknwiC9m_QCnEjLmq+gmwUA@mail.gmail.com>
References: <20171013081117.61e82817@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        avekceeb@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:47101 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751812AbdJMRbf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 13:31:35 -0400
Received: by mail-pg0-f68.google.com with SMTP id k7so1706753pga.3
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 10:31:35 -0700 (PDT)
In-Reply-To: <20171013081117.61e82817@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 8:11 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Hi,
>
> this is one more corner case found by syzkaller.
> I'm not sure that 'Networking' is the right category for this, but the panic
> was triggered by ioctl to /dev/net/tun...
>
>
> [   13.728009] BUG: unable to handle kernel NULL pointer dereference at
>   (null)
> [   13.728903] IP: run_timer_softirq+0x315/0x3f0
> [   13.729401] PGD 7bd8b067 P4D 7bd8b067 PUD 7bd7f067 PMD 0
> [   13.730040] Oops: 0002 [#1] SMP
> [   13.730400] Modules linked in:
> [   13.730747] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.14.0-rc4-with-tun #1
> [   13.731533] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> 1.0.0-prebuilt.qemu-project.org 04/01/2014
> [   13.732672] task: ffffffffa280f480 task.stack: ffffffffa2800000
> [   13.733332] RIP: 0010:run_timer_softirq+0x315/0x3f0
> [   13.733883] RSP: 0018:ffff961b7fc03ed0 EFLAGS: 00010086
> [   13.734467] RAX: ffff961b7bf070c0 RBX: ffff961b7fc10cc0 RCX:
> 0000000000000000
> [   13.735265] RDX: dead000000000200 RSI: 00000000fffffe01 RDI:
> ffff961b7fc10cc0
> [   13.736059] RBP: ffff961b7fc03f50 R08: 00000000fffba1c0 R09:
> ffff961b7fc11168
> [   13.736857] R10: ffff961b7fc03ee8 R11: ffff961b7fc10d30 R12:
> ffff961b7fc03ee0
> [   13.737652] R13: dead000000000200 R14: 0000000000000001 R15:
> ffff961b7bf070c0
> [   13.738463] FS:  0000000000000000(0000) GS:ffff961b7fc00000(0000)
> knlGS:0000000000000000
> [   13.739017] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   13.739339] CR2: 0000000000000000 CR3: 000000007bcf8000 CR4:
> 00000000000006f0
> [   13.739741] Call Trace:
> [   13.739882]  <IRQ>
> [   13.740000]  ? ktime_get+0x3b/0x90
> [   13.740196]  ? lapic_next_event+0x18/0x20
> [   13.740413]  __do_softirq+0xcf/0x2a8
> [   13.740606]  irq_exit+0xab/0xb0
> [   13.740778]  smp_apic_timer_interrupt+0x64/0x110
> [   13.741025]  apic_timer_interrupt+0x90/0xa0
> [   13.741250]  </IRQ>
> [   13.741367] RIP: 0010:default_idle+0x18/0xf0
> [   13.741596] RSP: 0018:ffffffffa2803e60 EFLAGS: 00000246 ORIG_RAX:
> ffffffffffffff10
> [   13.741998] RAX: 0000000080000000 RBX: ffffffffa293f5e0 RCX:
> 0000000000000000
> [   13.742370] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> 0000000000000000
> [   13.742750] RBP: ffffffffa2803e78 R08: 000000040a453dcd R09:
> ffff9c324031f930
> [   13.743128] R10: 0000000000000000 R11: 00000069d14f9aee R12:
> 0000000000000000
> [   13.743504] R13: 0000000000000000 R14: ffffffffa2a37780 R15:
> 0000000000000000
> [   13.743883]  arch_cpu_idle+0xa/0x10
> [   13.744072]  default_idle_call+0x1e/0x30
> [   13.744284]  do_idle+0x14f/0x1a0
> [   13.744458]  cpu_startup_entry+0x18/0x20
> [   13.744670]  rest_init+0xa9/0xb0
> [   13.744845]  start_kernel+0x3c6/0x3d3
> [   13.745043]  x86_64_start_reservations+0x24/0x26
> [   13.745291]  x86_64_start_kernel+0x6f/0x72
> [   13.745512]  secondary_startup_64+0xa5/0xa5
> [   13.745741] Code: 88 4c 39 65 88 0f 84 3b ff ff ff 49 8b 04 24 48 85 c0 74
> 56 4d 8b 3c 24 4c 89 7b 08 0f 1f 44 00 00 49 8b 17 49 8b 4f 08 48 85 d2 <48> 89
> 11 74 04 48 89 4a 08 41 f6 47 2a 20 49 c7 47 08 00 00 00
> [   13.746745] RIP: run_timer_softirq+0x315/0x3f0 RSP: ffff961b7fc03ed0
> [   13.747087] CR2: 0000000000000000
> [   13.747270] ---[ end trace 04d492145975c7cc ]---
> [   13.747516] Kernel panic - not syncing: Fatal exception in interrupt
> [   13.747946] Kernel Offset: 0x20a00000 from 0xffffffff81000000 (relocation
> range: 0xffffffff80000000-0xffffffffbfffffff)
> [   13.748515] ---[ end Kernel panic - not syncing: Fatal exception in
> interrupt
>
> Reproducer:
>
> #include <sys/syscall.h>
> #include <unistd.h>
> #include <stdio.h>
> #include <fcntl.h>
>
> char addr[40] = {0xcf, 0x0b, 0x0b, 0x99, 0x22, 0x33, 0x96, 0xdf, 0xbd, 0x2e,
> 0x29, 0x1b, 0x4d, 0xc0, 0x2a, 0xee, 0x03};
>
> void test() {
>     int fd = -1;
>     fd = open("/dev/net/tun", 0, 0);
>     syscall(__NR_ioctl, fd, 0x400454caul, addr);
> }
>
> #define max_iter 10
> int main(void) {
>         int iter;
>         for (iter = 0; iter<max_iter; iter++) {
>         test();
>             printf("done %d of %d\n", iter+1, max_iter);
>         }
>     return 0;
> }

I just make a patch to fix this, however it uncovers another bug,
so I am trying to fix both of them (if not more)...


Thanks!
