From: Dave Hansen <haveblue@us.ibm.com>
Subject: timer oops still present in 2.5.41-mm2
Date: Fri, 11 Oct 2002 14:48:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA74711.2050907@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@redhat.com>, lkml <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ingo, I hate to keep giving you false hope that this is fixed.  But, 
remember this is just -mm2, so any current BK fixes that change it 
wouldn't be in here, including the keyboard timer fixes that you were 
talking about.

Andrew, I noticed that you picked up Ingo's timer fix in 2.5.41-mm2 as
timer-tricks.patch.  Despite this, Specweb ran for about 10 minutes 
on, then failed with the oops below.  2.5.41, without Ingo's patch 
oopses in seconds.  It's very hard to get results out of Specweb when 
it is crashing this often.

Could a misbehaving timer be causing the TCP errors too?  I'd never 
seen them before 2.5.40.  I don't know how closely the TCP errors 
occurred to the timer oops.

Attempt to release TCP socket in state 1 e099ed60
Attempt to release TCP socket in state 1 f58cf460
Attempt to release TCP socket in state 1 e0f7d5a0
Attempt to release TCP socket in state 1 e106c4e0
Attempt to release TCP socket in state 1 e02667e0
Unable to handle kernel paging request at virtual address b800298c
  printing eip:
e027d3e0
*pde = 00000000
Oops: 0002
oprofile
CPU:    4
EIP:    0060:[<e027d3e0>]    Not tainted
EFLAGS: 00010282
EIP is at E nlm_debug_Rsmp_53445f68+0x1fdd5114/0xffd932a4
eax: f58cf698   ebx: e027d3d8   ecx: e164e6f8   edx: c0375ef8
esi: c0378060   edi: c0375b00   ebp: 00000292   esp: f7f97f14
ds: 0068   es: 0068   ss: 0068
Process swapper (pid: 0, threadinfo=f7f96000 task=f7fc0060)
Stack: 68c03780 c011fa30 e164e6f8 cb1101c8 00000000 f7f96000 00000001 
c011c9b5
        00000000 00000001 c0371960 fffffffe 00000080 c0356dc4 c0356dc4 
c011c6ba
        c0371960 00000010 00000004 00000000 00000000 00000046 c0110efd 
f7f96000
Call Trace:
  [<c011fa30>] run_timer_tasklet+0xe4/0x12c
  [<c011c9b5>] tasklet_hi_action+0x85/0xe0
  [<c011c6ba>] do_softirq+0x5a/0xac
  [<c0110efd>] smp_apic_timer_interrupt+0x111/0x118
  [<c0105334>] poll_idle+0x0/0x48
  [<c01079ca>] apic_timer_interrupt+0x1a/0x20
  [<c0105334>] poll_idle+0x0/0x48
  [<c0105356>] poll_idle+0x22/0x48
  [<c01053b3>] cpu_idle+0x37/0x48
  [<c0117f5e>] printk+0x11e/0x138

Code: a3 8c 29 00 b8 04 26 c0 a0 d1 27 e0 40 7b 37 c0 f0 d3 27 e0


-- 
Dave Hansen
haveblue@us.ibm.com
