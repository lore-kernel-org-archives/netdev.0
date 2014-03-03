From: Namjae Jeon <linkinjeon@gmail.com>
Subject: [BUG?] Null pointer dereference in nf_ct_delete_from_lists()
Date: Mon, 3 Mar 2014 18:50:23 +0900
Message-ID: <CAKYAXd_=6jDUgbUcsZtTrLqWPVngCh=tsrCeRc9ncRdCf3Kdaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo.

We got the below crash with our kernel(Kernel version: 3.8.13), not
sure exactly what caused this issue. So, sharing the backtrace.
Please help if there is any such known issue or any point which can
help in debugging this issue.

When we check at the address being referenced it is shown '00200200' -
which is actually the value for LIST_POISON2.
In this code path, POISON is marked after deletion in
function->hlist_nulls_del_rcu()
So, is this a case of deleting, already deleted node? or racy issue ?

It is grateful that you give me any valuable opinon to find the root cause.
Thanks.

Unable to handle kernel paging request at virtual address 00200200
pgd = c0003000
[00200200] *pgd=8000009e004003, *pmd=00000000

CPU: 2    Tainted: P           O  (3.8.13 #1)
 PC is at nf_ct_delete_from_lists+0x50/0xc0
 LR is at _raw_spin_lock_bh+0x2c/0x30
 pc : [<c031d9a0>]    lr : [<c038deac>]    psr: 20000113
 sp : d90bfe08  ip : d90bfdf0  fp : d90bfe1c
 r10: d5b24740  r9 : d5b24740  r8 : c031da10
 r7 : 00000102  r6 : d5b247bc  r5 : c054d3dc  r4 : d5b24740
 r3 : 00004533  r2 : 00200200  r1 : 00000277  r0 : d5b24740
 Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
 Control: 30c5387d  Table: b6b7c800  DAC: 55555555
 Process swapper/2 (pid: 0, stack limit = 0xd90be238)
 Stack: (0xd90bfe08 to 0xd90c0000)
 fe00:                   d5b24740 d90be000 d90bfe34 d90bfe20 c031da40 c031d95c
 fe20: d90bfe38 d901c000 d90bfe64 d90bfe38 c004d754 c031da1c 00000000 d901c000
 fe40: d901c000 d90be000 d5b247bc c0522084 00000000 c031da10 d90bfeac d90bfe68
 fe60: c004e8c8 c004d720 c04736a0 d901c820 00200200 d90bfe78 d90bfe78 d90bfe78
 fe80: c0044d24 00000001 d90be000 00000004 c0522084 c0522088 d90be000 00000101
 fea0: d90bfefc d90bfeb0 c0045074 c004e72c 0000001e 0000000a c061f568 00200040
 fec0: 0000000a 00000002 00000004 00000102 00000008 d90be000 0000001e 00000000
 fee0: c0554cb4 c0396ab0 d90be000 c0536150 d90bff14 d90bff00 c004576c c0044f78
 ff00: d90bff18 c051e2f4 d90bff34 d90bff18 c0013ba0 c00456d0 00000010 fef92000
 ff20: c0531478 d90bff58 d90bff54 d90bff38 c00085fc c0013b34 c0013f18 60000013
 ff40: ffffffff d90bff8c d90bffac d90bff58 c038e304 c00085ac ffffffed 00f52000
 ff60: c053290c 00000000 d90be000 c05321b4 d90be000 c0554748 c0396ab0 d90be000
 ff80: c0536150 d90bffac d90bffb0 d90bffa0 c0013f2c c0013f18 60000013 ffffffff
 ffa0: d90bffdc d90bffb0 c0014184 c0013ee0 00000000 00000002 00000000 30c2387d
 ffc0: c0554a1c 9e007000 412fc0f3 00000000 d90bfff4 d90bffe0 c038236c c001408c
 ffe0: c0381870 b7046340 00000000 d90bfff8 9e381888 c0382238 ffffffff ffffffff

 Backtrace:
 [<c031d950>] (nf_ct_delete_from_lists+0x0/0xc0) from [<c031da40>]
(death_by_timeout+0x30/0x68)
  r5 90be000 r4 5b24740
 [<c031da10>] (death_by_timeout+0x0/0x68) from [<c004d754>]
(call_timer_fn+0x40/0x158)
  r4 901c000 r3 90bfe38
 [<c004d714>] (call_timer_fn+0x0/0x158) from [<c004e8c8>]
(run_timer_softirq+0x1a8/0x280)
 [<c004e720>] (run_timer_softirq+0x0/0x280) from [<c0045074>]
(__do_softirq+0x108/0x2cc)
 [<c0044f6c>] (__do_softirq+0x0/0x2cc) from [<c004576c>] (irq_exit+0xa8/0xb0)
 [<c00456c4>] (irq_exit+0x0/0xb0) from [<c0013ba0>] (handle_IRQ+0x78/0x108)
  r4:c051e2f4 r3 90bff18
 [<c0013b28>] (handle_IRQ+0x0/0x108) from [<c00085fc>]
(gic_handle_irq+0x5c/0xa4)
  r6 90bff58 r5:c0531478 r4:fef92000 r3:00000010
 [<c00085a0>] (gic_handle_irq+0x0/0xa4) from [<c038e304>] (__irq_svc+0x44/0x78)
 Exception stack(0xd90bff58 to 0xd90bffa0)
 ff40:                                                       ffffffed 00f52000
 ff60: c053290c 00000000 d90be000 c05321b4 d90be000 c0554748 c0396ab0 d90be000
 ff80: c0536150 d90bffac d90bffb0 d90bffa0 c0013f2c c0013f18 60000013 ffffffff
  r7 90bff8c r6:ffffffff r5:60000013 r4:c0013f18
 [<c0013ed4>] (default_idle+0x0/0x64) from [<c0014184>] (cpu_idle+0x104/0x168)
 [<c0014080>] (cpu_idle+0x0/0x168) from [<c038236c>]
(secondary_start_kernel+0x140/0x160)
 [<c038222c>] (secondary_start_kernel+0x0/0x160) from [<9e381888>] (0x9e381888)
  r4:b7046340 r3:c0381870
Code: e7821003 e5943014 e5942018 e3130001 (e5823000)
