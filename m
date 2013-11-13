From: Dave Jones <davej@redhat.com>
Subject: oops in tcp_get_metrics, followed by lockup.
Date: Wed, 13 Nov 2013 15:45:43 -0500
Message-ID: <20131113204543.GA26715@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab3KMUpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 15:45:52 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rADKjqCZ012444
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 15:45:52 -0500
Received: from gelk.kernelslacker.org ([10.3.113.13])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id rADKjkqY017028
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 15:45:52 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.7) with ESMTP id rADKjhUO028501
	for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 15:45:43 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id rADKjh1E028500
	for netdev@vger.kernel.org; Wed, 13 Nov 2013 15:45:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My fuzzer just hit this on v3.12-7033-g42a2d923cc34

Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in: fuse hidp tun snd_seq_dummy bnep nfnetlink rfcomm ipt_ULOG can_bcm nfc caif_socket caif af_802154 phonet af_rxrpc bluetooth rfkill can_raw can llc2 pppoe pppox ppp
_generic slhc irda crc_ccitt rds scsi_transport_iscsi af_key rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 xfs libcrc32c coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_p
clmul crc32c_intel ghash_clmulni_intel usb_debug snd_hda_codec_realtek snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc snd_ti
mer e1000e snd ptp shpchp soundcore pps_core serio_raw
CPU: 1 PID: 16002 Comm: trinity-child1 Not tainted 3.12.0+ #2
task: ffff88023cd75580 ti: ffff88009ee26000 task.ti: ffff88009ee26000
RIP: 0010:[<ffffffff81658dd2>]  [<ffffffff81658dd2>] tcp_get_metrics+0x62/0x420
RSP: 0018:ffff880244a03d28  EFLAGS: 00010246
RAX: 0000000000000002 RBX: ffff88009c77a4c0 RCX: 0000000000000001
RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff88009c77a4c0
RBP: ffff880244a03d78 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 00000000000010ac R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000018 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Stack:
 000000018165a6b5 ffffffff000010ac 0000000000000246 0000000044a00002
 ffffffff81c480a0 ffff88009c77a4c0 0000000000000000 0000000000000000
 0000000000000001 0000000000000000 ffff880244a03db8 ffffffff8165a740
Call Trace:
 <IRQ> 
 [<ffffffff8165a740>] tcp_fastopen_cache_set+0x90/0x280
 [<ffffffff8165a6b5>] ? tcp_fastopen_cache_set+0x5/0x280
 [<ffffffff8164f3a7>] tcp_retransmit_timer+0x1d7/0x930
 [<ffffffff8164fcb0>] ? tcp_write_timer_handler+0x1b0/0x1b0
 [<ffffffff8164fba0>] tcp_write_timer_handler+0xa0/0x1b0
 [<ffffffff8164fd2c>] tcp_write_timer+0x7c/0x80
 [<ffffffff81063c1a>] call_timer_fn+0x8a/0x340
 [<ffffffff81063b95>] ? call_timer_fn+0x5/0x340
 [<ffffffff8164fcb0>] ? tcp_write_timer_handler+0x1b0/0x1b0
 [<ffffffff81064114>] run_timer_softirq+0x244/0x3a0
 [<ffffffff8105aa9c>] __do_softirq+0xfc/0x490
 [<ffffffff8105b28d>] irq_exit+0x13d/0x160
 [<ffffffff8172fe25>] smp_apic_timer_interrupt+0x45/0x60
 [<ffffffff8172eaaf>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff810d559d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff811560af>] ? free_hot_cold_page+0xff/0x180
 [<ffffffff81156176>] free_hot_cold_page_list+0x46/0x160
 [<ffffffff8115c21e>] release_pages+0x8e/0x1f0
 [<ffffffff8118c135>] free_pages_and_swap_cache+0x95/0xb0
 [<ffffffff81175acc>] tlb_flush_mmu.part.73+0x4c/0x90
 [<ffffffff81176115>] tlb_finish_mmu+0x55/0x60
 [<ffffffff81180d84>] exit_mmap+0xf4/0x170
 [<ffffffff8105108b>] mmput+0x6b/0x100
 [<ffffffff810559e8>] do_exit+0x278/0xcb0
 [<ffffffff817250e1>] ? _raw_spin_unlock+0x31/0x50
 [<ffffffff810d53c6>] ? trace_hardirqs_on_caller+0x16/0x1e0
 [<ffffffff810d559d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff810577ec>] do_group_exit+0x4c/0xc0
 [<ffffffff81057874>] SyS_exit_group+0x14/0x20
 [<ffffffff8172e064>] tracesys+0xdd/0xe2
Code: 0a 0f 85 c2 01 00 00 48 8b 47 38 48 8b 57 40 48 89 44 24 08 48 8b 47 40 48 89 54 24 10 48 33 47 38 49 89 c6 49 c1 ee 20 41 31 c6 <49> 8b 45 18 b9 20 00 00 00 45 69 f6 01 00 37 9e 48 8b 80 d8 04 
RIP  [<ffffffff81658dd2>] tcp_get_metrics+0x62/0x420
 RSP <ffff880244a03d28>
CR2: 0000000000000018
---[ end trace c25bf4de9744120a ]---


The disassembly looks like it happened here :-


static inline u32 ipv6_addr_hash(const struct in6_addr *a)
{
#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
        const unsigned long *ul = (const unsigned long *)a;
        unsigned long x = ul[0] ^ ul[1];
    10db:       48 8b 47 40             mov    0x40(%rdi),%rax
    10df:       48 89 54 24 10          mov    %rdx,0x10(%rsp)
    10e4:       48 33 47 38             xor    0x38(%rdi),%rax

        return (u32)(x ^ (x >> 32));
    10e8:       49 89 c6                mov    %rax,%r14
    10eb:       49 c1 ee 20             shr    $0x20,%r14
    10ef:       41 31 c6                xor    %eax,%r14d
    10f2:       49 8b 45 18             mov    0x18(%r13),%rax    <<<< Faulting instruction.
    10f6:       b9 20 00 00 00          mov    $0x20,%ecx
}
