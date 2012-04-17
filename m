From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: 3.4.0-rc2: skb_put() -> skb_over_panic
Date: Wed, 18 Apr 2012 00:15:00 +0400
Message-ID: <CAA1sL1SJyY7fYJn7OKqo5Pa=b4-r9DW90-5WVGBf==tFjVEBpg@mail.gmail.com>
References: <CAA1sL1QTRKnfvCnHWjbSJ-hq6dgZK+KGDPVTrOhsfZcFTs01Mw@mail.gmail.com>
	<1334502964.28012.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:51848 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab2DQUPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 16:15:02 -0400
In-Reply-To: <1334502964.28012.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 April 2012 19:16, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2012-04-15 at 16:24 +0400, Alexander Beregalov wrote:
>> Hi
>>
>> kernel 3.4.0-rc2-00333-g668ce0a
>>
>> calltrace is lost on netconsole, sorry.
>>
>> ethernet is realtek/r8169
>>
>> It happened already two times with rtorrent, perhaps I can reproduce
>> it, what else can I provide to you?
>>
> full stack trace needed please.
>

This time calltrace is different (I saw few last lines of calltrace on
a display, but not enough) and netconsole transmitted complete
message, but perhaps it is the same problem. At least 'end' is the
same.


skb_over_panic: text:ffffffff8136d919 len:1248 put:932
head:ffff8800babcf800 data:ffff8800babcfd10 tail:0x9f0 end:0x6c0
dev:<NULL>
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:127!
invalid opcode: 0000 [#1] SMP
CPU 3
Modules linked in:

Pid: 1926, comm: rtorrent Not tainted 3.4.0-rc2-00333-g668ce0a #1
            /D525MW
RIP: 0010:[<ffffffff8132414a>]  [<ffffffff8132414a>] skb_put+0x7c/0x86
RSP: 0018:ffff8800bed83d60  EFLAGS: 00010246
RAX: 0000000000000098 RBX: ffff8800b0b244c0 RCX: 000000000000003d
RDX: 000000000000000d RSI: 0000000000000046 RDI: ffffffff8162a0b0
RBP: ffff8800bed83d80 R08: 0000000000000001 R09: 0000000000000000
R10: ffff88002ed840c0 R11: 00000000007e28f6 R12: ffff8800b9cb9180
R13: ffff8800b9cb96c0 R14: ffff8800b9cb91a8 R15: ffff8800b0b245a0
FS:  00007fe639e75720(0000) GS:ffff8800bed80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fe63571a000 CR3: 00000000b53fa000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rtorrent (pid: 1926, threadinfo ffff8800bb0a0000, task ffff8800bb1dddc0)
Stack:
 00000000000009f0 00000000000006c0 ffffffff814d06e7 ffff8800b9cb9180
 ffff8800bed83de0 ffffffff8136d919 ffff8800000003a4 0000013c81536640
 ffff8800b0b245a0 000000cc00000006 ffff8800b0b244c0 ffff8800b0b244c0
Call Trace:
 <IRQ>
 [<ffffffff8136d919>] tcp_retransmit_skb+0x29a/0x529
 [<ffffffff8136eebd>] tcp_retransmit_timer+0x358/0x4e7
 [<ffffffff8136f0e8>] tcp_write_timer+0x9c/0x17d
 [<ffffffff81035bd0>] run_timer_softirq+0x1eb/0x2bf
 [<ffffffff8136f04c>] ? tcp_retransmit_timer+0x4e7/0x4e7
 [<ffffffff810184e9>] ? native_smp_send_reschedule+0x4f/0x51
 [<ffffffff8102fb52>] __do_softirq+0xbf/0x17d
 [<ffffffff810188ec>] ? lapic_next_event+0x18/0x1c
 [<ffffffff813c05cc>] call_softirq+0x1c/0x30
 [<ffffffff810033d6>] do_softirq+0x33/0x69
 [<ffffffff8102fdc6>] irq_exit+0x44/0x9c
 [<ffffffff81018c6f>] smp_apic_timer_interrupt+0x86/0x94
 [<ffffffff813bfe47>] apic_timer_interrupt+0x67/0x70
 <EOI>
 [<ffffffff8131d87e>] ? sock_sendmsg+0xe6/0x106
 [<ffffffff8135fb7b>] ? tcp_poll+0xaf/0x168
 [<ffffffff810ff814>] ? ep_send_events_proc+0x67/0x116
 [<ffffffff8131b8ef>] sock_poll+0x15/0x17
 [<ffffffff810ff823>] ep_send_events_proc+0x76/0x116
 [<ffffffff810ff7ad>] ? ep_read_events_proc+0x99/0x99
 [<ffffffff810fff24>] ep_scan_ready_list.clone.6+0x8f/0x16f
 [<ffffffff81100277>] ep_poll+0x25f/0x2e2
 [<ffffffff8131e886>] ? sys_accept4+0x133/0x15f
 [<ffffffff81100d8e>] sys_epoll_wait+0x90/0xae
 [<ffffffff813bf2e6>] system_call_fastpath+0x1a/0x1f
Code: 8b 57 60 48 89 44 24 10 8b 87 ac 00 00 00 48 89 44 24 08 31 c0
8b bf a8 00 00 00 48 89 3c 24 48 c7 c7 43 07 4d 81 e8 2c 27 09 00 <0f>
0b 89 c0 49 8d 04 00 c9 c3 55 48 89 e5 41 57 41 56 41 55 41
RIP  [<ffffffff8132414a>] skb_put+0x7c/0x86
 RSP <ffff8800bed83d60>
---[ end trace a721715cd86be064 ]---
