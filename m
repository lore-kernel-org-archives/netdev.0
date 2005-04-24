From: Reuben Farrelly <reuben-lkml@reub.net>
Subject: Re: Fw: 2x crash in 2.6.12-rc2-mm3
Date: Sun, 24 Apr 2005 12:54:21 +1200
Message-ID: <6.2.3.0.2.20050424125154.04124008@tornado.reub.net>
References: <20050423175021.1272a974.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
In-Reply-To: <20050423175021.1272a974.akpm@osdl.org>
References: <20050423175021.1272a974.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I also had this one last night (still with rc2-mm3) but hadn't yet 
gotten around to sending it on...

BUG: soft lockup detected on CPU#1!

Pid: 0, comm:              swapper
EIP: 0060:[<c03404f1>] CPU: 1
EIP is at _spin_lock+0x52/0x63
  EFLAGS: 00000202    Not tainted  (2.6.12-rc2-mm3)
EAX: 00000001 EBX: d3454e24 ECX: d34550e8 EDX: 00000000
ESI: dff92000 EDI: d3454e24 EBP: c030a9bd DS: 007b ES: 007b
CR0: 8005003b CR2: b78ba004 CR3: 0c6b1000 CR4: 000006d0
  [<c030a9cf>] tcp_delack_timer+0x12/0x1e3
  [<c01246fe>] run_timer_softirq+0xd6/0x1a6
  [<c0116b14>] rebalance_tick+0xfb/0x11a
  [<c01206f2>] __do_softirq+0x72/0xdc
  [<c012078f>] do_softirq+0x33/0x36
  [<c012085c>] irq_exit+0x40/0x42
  [<c01039a8>] apic_timer_interrupt+0x1c/0x24
  [<c010127a>] mwait_idle+0x25/0x43
  [<e090bacc>] acpi_processor_idle+0xf0/0x250 [processor]
  [<c01010c4>] cpu_idle+0x4e/0x63

I imagine this may be related, if it's not the same problem?  The 
traces look similar but not identical.

reuben


At 12:50 p.m. 24/04/2005, Andrew Morton wrote:

>Looks like a deadlock in neigh_timer_handler().
>
>Straightforward, I think - foo_lock_bh() is not sufficient to prevent timer
>handlers from executing.
>
>Whcih probably means someone has already fixed it?
>
>
>
>Begin forwarded message:
>
>Date: Sun, 17 Apr 2005 01:59:01 +1200
>From: Reuben Farrelly <reuben-lkml@reub.net>
>To: Andrew Morton <akpm@osdl.org>
>Subject: 2x crash in 2.6.12-rc2-mm3
>
>
>Hi Andrew,
>
>Had 2x crashes over about 3 hours with rc2-mm3 tonight (just flown
>back from Sydney, so when I got home rebooted from rc2-mm1 which was
>good, to rc2-mm3 which so far is more unstable).
>
>Photo at http://www.reub.net/kernel/P4160257.JPG   Serial console
>output probably not too hard if required.
>
>Box is a single CPU/HT, P4 with Intel Gigabit Lan and compiled with
>FC4 gcc4 (latest)
>
>I didn't see this one show up on lkml, but my guess is that this is
>something network related?
>
>reuben
