From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3973] New: Panic when using Miredo IPv6 tunnel
 (TUN/TAP)
Date: Thu, 30 Dec 2004 13:27:07 -0800
Message-ID: <20041230132707.253d0a79.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 30 Dec 2004 12:47:13 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3973] New: Panic when using Miredo IPv6 tunnel (TUN/TAP)


http://bugme.osdl.org/show_bug.cgi?id=3973

           Summary: Panic when using Miredo IPv6 tunnel (TUN/TAP)
    Kernel Version: 2.6.10
            Status: NEW
          Severity: high
             Owner: yoshfuji@linux-ipv6.org
         Submitter: kernelbug.20.jj05@spamgourmet.com


Distribution: Debian (testing)
Hardware Environment: Pentium III (Running under VMWare)
Software Environment: Clean install, miredo 0.3.2, GCC 3.3.4 (Debian 1:3.3.4-13)
Kernel: Linus' 2.6.10, configuration from arch/i386/defconfig, with the
following main changes: CONFIG_PCNET_32=y CONFIG_TUN=m CONFIG_IPV6=m
CONFIG_MPENTIUM3=y

Problem Description:
Kernel panic after creating a tunnel using miredo and waiting some time.

Steps to reproduce:
Using miredo 0.3.2 (http://www.simphalempin.com/dev/miredo/)
1. ./miredo -f -v teredo.via.ecp.fr
2. Wait about 15 minutes.

Crash log:
Linux version 2.6.10s (root@debian) (gcc version 3.3.4 (Debian 1:3.3.4-13)) #1
SMP Tue Dec 28 23:04:53 CET 2004
[snip]
Universal TUN/TAP device driver 1.5 (C)1999-2002 Maxim Krasnyansky
Unable to handle kernel paging request at virtual address 61696265
 printing eip:
c018c7d5
*pde = 00000000
Oops: 0000 [#1]
PREEMPT SMP 
Modules linked in: tun ipv6
CPU:    0
EIP:    0060:[<c018c7d5>]    Not tainted VLI
EFLAGS: 00010246   (2.6.10s) 
EIP is at remove_proc_entry+0x25/0x150
eax: 00000000   ebx: c2c92ec0   ecx: ffffffff   edx: c344fb00
esi: c3fe0400   edi: 61696265   ebp: c04c6fc4   esp: c04c6f38
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c04c6000 task=c03f5b40)
Stack: 00000000 c03f5b40 c04c6f70 c0118443 61696265 c2c92ec0 c3fe0400 00000000 
       c489e094 61696265 c344fb00 c2c92ec0 c487bd95 c2c92ec0 c031dd70 c1084960 
       c347b9c0 00000000 c346c900 c031e0de c2c92ec0 c346c040 c346c900 c04f98c0 
Call Trace:
 [<c0118443>] scheduler_tick+0x123/0x4c0
 [<c489e094>] snmp6_unregister_dev+0x44/0x60 [ipv6]
 [<c487bd95>] in6_dev_finish_destroy+0x35/0xd0 [ipv6]
 [<c031dd70>] dst_run_gc+0x0/0x110
 [<c031e0de>] dst_destroy+0xae/0xd0
 [<c031de52>] dst_run_gc+0xe2/0x110
 [<c031dd70>] dst_run_gc+0x0/0x110
 [<c031dd70>] dst_run_gc+0x0/0x110
 [<c0125faa>] run_timer_softirq+0xda/0x1a0
 [<c0121c1a>] __do_softirq+0xba/0xd0
 [<c01057ca>] do_softirq+0x4a/0x60
 =======================
 [<c013aeb9>] irq_exit+0x39/0x40
 [<c0103bac>] apic_timer_interrupt+0x1c/0x24
 [<c0101030>] default_idle+0x0/0x40
 [<c010105c>] default_idle+0x2c/0x40
 [<c01010f2>] cpu_idle+0x42/0x60
 [<c048c98f>] start_kernel+0x14f/0x170
 [<c048c3a0>] unknown_bootoption+0x0/0x1e0
Code: b4 26 00 00 00 00 57 56 53 83 ec 14 8b 54 24 28 8b 4c 24 24 85 d2 89 4c 24
10 0f 84 08 01 00 00 8b 7c 24 10 31 c0 b9 ff ff ff ff <f2> ae f7 d1 49 8b 42 34
89 ce 8d 5a 34 85 c0 74 2a 8b 3b 89 34 
 <0>Kernel panic - not syncing: Fatal exception in interrupt

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
