From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at
 init time
Date: Tue, 12 Jul 2011 06:16:55 +0200
Message-ID: <1310444215.2860.28.camel@edumazet-laptop>
References: <1310421182.2860.22.camel@edumazet-laptop>
	 <CAL3LdT7WNrkDk2WrTnDnwYJ2raoNJdG5v4q=gk4o8hc2KR1Q_w@mail.gmail.com>
	 <20110711.193359.1440272794251078589.davem@davemloft.net>
	 <1310438432.2438.26.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"greearb@candelatech.com" <greearb@candelatech.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64913 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab1GLERC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 00:17:02 -0400
Received: by wwe5 with SMTP id 5so4530851wwe.1
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 21:17:00 -0700 (PDT)
In-Reply-To: <1310438432.2438.26.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 juillet 2011 =C3=A0 19:40 -0700, Jeff Kirsher a =C3=A9crit =
:
> On Mon, 2011-07-11 at 19:33 -0700, David Miller wrote:
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Mon, 11 Jul 2011 16:51:23 -0700
> >=20
> > > On Mon, Jul 11, 2011 at 14:53, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
> > >> Note : This patch is untested, I dont have the hardware
> > >>
> > >> Thanks
> > >>
> > >> [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at i=
nit time
> > >>
> > >> In process and sleep allowed context, favor GFP_KERNEL allocatio=
ns over
> > >> GFP_ATOMIC ones.
> > >>
> > >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > >> CC: Ben Greear <greearb@candelatech.com>
> > >> CC: Bruce Allan <bruce.w.allan@intel.com>
> > >> ---
> > >>  drivers/net/e1000e/e1000.h  |    2 +-
> > >>  drivers/net/e1000e/netdev.c |   33 +++++++++++++++++-----------=
-----
> > >>  2 files changed, 18 insertions(+), 17 deletions(-)
> > >>
> > >=20
> > > Thanks Eric!  I have added the patch to my queue.
> >=20
> > You can't until I put patch #1 into my tree, which adds the
> > new interfaces used by this patch.
>=20
> I applied patch #1 to my queue as well (for testing purposes) since I
> saw that patch #2 was dependent.  If it passes testing, I (or Bruce)
> will just ACK patch #2, that way you can apply both patches at the sa=
me
> time.

I started this work and CC Ben Greear on this one because he sent a bug
report yesterday in case the interface is restarted.

(Crash in e1000e driver, 3.0-rc6+)

BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
08
IP: [<ffffffffa024ea92>] e1000_alloc_rx_buffers+0x58/0x14a [e1000e]
PGD 0
Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
CPU 0
Modules linked in: macvlan pktgen iscsi_tcp libiscsi_tcp libiscsi scsi_=
transport_iscsi fuse ip6table_filter ip6_tables ebtable_nat ]

Pid: 2367, comm: kworker/0:2 Tainted: G        W   3.0.0-rc6+ #20 Super=
micro X7DBU/X7DBU
RIP: 0010:[<ffffffffa024ea92>]  [<ffffffffa024ea92>] e1000_alloc_rx_buf=
fers+0x58/0x14a [e1000e]
RSP: 0018:ffff8801143ddc70  EFLAGS: 00010206
RAX: ffff880128b08090 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000100 RSI: 00000000000000ff RDI: ffff880122d3c900
RBP: ffff8801143ddcc0 R08: ffff8801143ddb80 R09: ffff8801143ddbe0
R10: dead000000200200 R11: dead000000100100 R12: ffff880122d3c900
R13: 0000000000000000 R14: ffff880122818558 R15: 00000000000000ff
=46S:  0000000000000000(0000) GS:ffff88012fc00000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 0000000001a03000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:2 (pid: 2367, threadinfo ffff8801143dc000, task ffff8=
801259267e0)
Stack:
  ffff880122d3c900 ffff880122d3c000 000005f222818558 ffff880128b08090
  ffff8801143ddca0 ffff880122d3c900 ffff880122818558 0000000000001000
  0000000004008002 ffffffffa024d672 ffff8801143ddcf0 ffffffffa024a795
Call Trace:
  [<ffffffffa024d672>] ? e1000e_reinit_locked+0x5f/0x5f [e1000e]
  [<ffffffffa024a795>] e1000_configure+0x507/0x510 [e1000e]
  [<ffffffffa024a7af>] e1000e_up+0x11/0xc9 [e1000e]
  [<ffffffffa024d665>] e1000e_reinit_locked+0x52/0x5f [e1000e]
  [<ffffffffa024dd0e>] e1000_reset_task+0x69c/0x6ab [e1000e]
  [<ffffffff8106128e>] ? process_one_work+0x17b/0x41d
  [<ffffffff81041b91>] ? get_parent_ip+0x11/0x41
  [<ffffffffa024d672>] ? e1000e_reinit_locked+0x5f/0x5f [e1000e]
  [<ffffffff81061343>] process_one_work+0x230/0x41d
  [<ffffffff8106128e>] ? process_one_work+0x17b/0x41d
  [<ffffffff8106379f>] worker_thread+0x133/0x217
  [<ffffffff8106366c>] ? manage_workers+0x191/0x191
  [<ffffffff81066f9c>] kthread+0x7d/0x85
  [<ffffffff81485ee4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8147f0d8>] ? retint_restore_args+0x13/0x13
  [<ffffffff81066f1f>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81485ee0>] ? gs_change+0x13/0x13
Code: 00 00 89 45 c4 41 0f b7 5e 18 48 8b 87 28 05 00 00 41 89 dd 48 05=
 90 00 00 00 4d 6b ed 28 4d 03 6e 20 48 89 45 c8 e9 d5 00 00
  8b 45 08 48 85 c0 74 14 48 89 c7 31 f6 48 89 45 b0 e8 29 85
RIP  [<ffffffffa024ea92>] e1000_alloc_rx_buffers+0x58/0x14a [e1000e]
  RSP <ffff8801143ddc70>
CR2: 0000000000000008
---[ end trace cddc6b4ca68ac6e9 ]---


I feel that this driver assumes the refill is done without any
OutOfMemory conditions, I've not yet found how to fix this bad
assumption, only make the refill use GFP_KERNEL to avoid OOM



