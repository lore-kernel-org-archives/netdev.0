From: Andrew Morton <akpm@digeo.com>
Subject: Fw: 2.4.21 oops
Date: Mon, 16 Jun 2003 15:30:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616153029.0c8f2a20.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This kills 2.5.71++ as well.

Program received signal SIGTRAP, Trace/breakpoint trap.
skb_over_panic (skb=0xc0400330, sz=-1068485248, here=0xc034540e) at net/core/skbuff.c:87
87              BUG();
(gdb) bt
#0  skb_over_panic (skb=0xc0400330, sz=-1068485248, here=0xc034540e) at net/core/skbuff.c:87
#1  0xc0345417 in add_grhead (skb=0xce2e7b68, pmc=0xcc7e05f0, type=44, ppgr=0x2c) at include/linux/skbuff.h:840
#2  0xc03454fe in add_grec (skb=0xce2e7b68, pmc=0xcc7e05f0, type=4, gdeleted=0, sdeleted=0) at net/ipv6/mcast.c:1325
#3  0xc0345b9b in mld_send_cr (idev=0xcecc9290) at net/ipv6/mcast.c:1513
#4  0xc03468e1 in mld_ifc_timer_expire (data=3469513360) at net/ipv6/mcast.c:1904
#5  0xc012c0c7 in run_timer_softirq (h=0xc0504a08) at kernel/timer.c:428
#6  0xc012815a in do_softirq () at kernel/softirq.c:96
#7  0xc0119783 in smp_apic_timer_interrupt (regs=
      {ebx = -1072657500, ecx = 0, edx = -1068474368, esi = -1068474368, edi = -1072672768, ebp = -1068466236, eax = 0, xds = -1072693125, xes = -1068498821, orig_eax = -17, eip = -1072657456, xcs = 96, eflags = 582, esp = -1068466220, xss = -1072657306})
    at arch/i386/kernel/apic.c:1061
#8  0xc010b8c2 in apic_timer_interrupt ()
#9  0xc0108c66 in cpu_idle () at arch/i386/kernel/process.c:146
#10 0xc010506d in rest_init () at init/main.c:375
#11 0xc0508862 in start_kernel () at init/main.c:467


Begin forwarded message:

Date: Mon, 16 Jun 2003 13:40:11 +0200 (CEST)
From: Andrzej Sosnowski <raptor@lists.raptor.pl>
To: linux-kernel@vger.kernel.org
Subject: 2.4.21 oops


Hi.

Kernel makes an oops while executing the following script:

#!/bin/sh
for IP in `/usr/bin/seq 3 500`; do
  ip addr add 3ffe:80ee:c1d::$IP/48 dev eth0
  ip addr add 3ffe:80ee:c1d::a:$IP/48 dev eth0
done

Result:
kernel BUG sched.c 564!
(sorry for incomplete oops message)

Tested on:
  debian 2.4.21
  debian/redhat 2.4.21-grsec 1.9.10
  redhat 2.4.21-uv2-grsec 1.9.10

This script with 2.4.20 working fine.

-- 
____________________________________________________________________
andrzej sosnowski * raptor@raptor.pl * http://raptor.pl * 0xB71774A2







