From: Phil Oester <kernel@linuxace.com>
Subject: bpf_jit_compile issues on x86_64
Date: Tue, 17 Jan 2012 18:27:09 -0800
Message-ID: <20120118022709.GA4167@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47856 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756531Ab2ARC1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 21:27:13 -0500
Received: by mail-iy0-f174.google.com with SMTP id f6so5183538iag.19
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 18:27:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a 3.1.8 kernel, I've had a few snort boxes panic when using the new bpf_jit
code.  Setting bpf_jit_enable back to 0 solves the problem.  Below is the
warning, followed by the panic.  I've checked the current Linus tree, but
other than a03ffcf8 (which exists in 3.1.8) I don't see anything new in this
area.  Any ideas?  Eric?

Thanks,
Phil


WARNING: at arch/x86/net/bpf_jit_comp.c:608 bpf_jit_compile+0xde8/0xe70()
Hardware name: PowerEdge 2950
Modules linked in: iptable_nat ipt_LOG xt_limit xt_pkttype xt_tcpudp xt_state xt_multiport iptable_filter ip_tables x_tables nf_nat_tftp nf_nat_ftp nf_nat nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack scsi_wait_scan bnx2 ipmi_devintf ipmi_si ipmi_msghandler e1000e iTCO_wdt ata_piix megaraid_sas
Pid: 1254, comm: snort-plain Not tainted 3.1.8-asdf.2.fc16.x86_64 #1
Call Trace:
 [<ffffffff8103024b>] ? warn_slowpath_common+0x7b/0xc0
 [<ffffffff81023b18>] ? bpf_jit_compile+0xde8/0xe70
 [<ffffffff8125e045>] ? sk_chk_filter+0x255/0x330
 [<ffffffff8125e296>] ? sk_attach_filter+0xa6/0x180
 [<ffffffff81240974>] ? sock_setsockopt+0x374/0x7c0
 [<ffffffff8123cd76>] ? sys_setsockopt+0xc6/0xe0
 [<ffffffff812d0e7b>] ? system_call_fastpath+0x16/0x1b
---[ end trace 6b276feef74ef40a ]---
BUG: unable to handle kernel paging request at 00000000a0000000
IP: [<ffffffff812437f8>] skb_release_head_state+0x28/0xe0
PGD 223535067 PUD 0
Oops: 0002 [#1] SMP
CPU 4
Modules linked in: iptable_nat ipt_LOG xt_limit xt_pkttype xt_tcpudp xt_state xt_multiport iptable_filter ip_tables x_tables nf_nat_tftp nf_nat_ftp nf_nat nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack scsi_wait_scan bnx2 ipmi_devintf ipmi_si ipmi_msghandler e1000e iTCO_wdt ata_piix megaraid_sas

Pid: 0, comm: kworker/0:1 Tainted: G        W   3.1.8-asdf.2.fc16.x86_64 #1 Dell Inc. PowerEdge 2950/xxxxx
RIP: 0010:[<ffffffff812437f8>]  [<ffffffff812437f8>] skb_release_head_state+0x28/0xe0
RSP: 0018:ffff88022fd03c80  EFLAGS: 00010206
RAX: 0000000000000001 RBX: ffff8802235c4000 RCX: ffff880220c4c000
RDX: ffff88022617b000 RSI: 000000000000000c RDI: 00000000a0000000
RBP: ffff880226181c00 R08: ffff880224101840 R09: 000000000000003c
R10: 0000000000000009 R11: 0000000000000000 R12: 000000000000003c
R13: 0000000000000005 R14: ffff880220c4c000 R15: ffff88022410184e
FS:  0000000000000000(0000) GS:ffff88022fd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000a0000000 CR3: 0000000223490000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:1 (pid: 0, threadinfo ffff8802260d6000, task ffff8802260d8000)
Stack:
 ffff8802235c4000 ffffffff812436e9 ffff8802235c4000 ffffffff812bcf3c
 ffff880224101840 000000010010000f 0000000000000042 0000000000000000
 0000002e1d6a0001 ffff880224101800 0000008027002900 ffff880220c4c000
Call Trace:
 <IRQ>
 [<ffffffff812436e9>] ? __kfree_skb+0x9/0x90
 [<ffffffff812bcf3c>] ? tpacket_rcv+0x10c/0x660
 [<ffffffff810a9cb4>] ? kmem_cache_free+0x14/0x90
 [<ffffffff8124abc3>] ? __netif_receive_skb+0x363/0x400
 [<ffffffff8124dd30>] ? netif_receive_skb+0x70/0x80
 [<ffffffff8124ecab>] ? napi_gro_receive+0x9b/0xb0
 [<ffffffff8124de08>] ? napi_skb_finish+0x38/0x50
 [<ffffffffa005b1f8>] ? e1000_clean_rx_irq+0x278/0x380 [e1000e]
 [<ffffffffa005a9d6>] ? e1000_clean+0x76/0x2c0 [e1000e]
 [<ffffffff8124e631>] ? net_rx_action+0xe1/0x160
 [<ffffffff81035938>] ? __do_softirq+0x98/0x120
 [<ffffffff812d2d6c>] ? call_softirq+0x1c/0x26
 [<ffffffff81003acd>] ? do_softirq+0x4d/0x80
 [<ffffffff8100398c>] ? do_IRQ+0x5c/0xd0
 [<ffffffff812d086b>] ? common_interrupt+0x6b/0x6b
 <EOI>
 [<ffffffff812ce930>] ? __schedule+0x230/0x5f0
 [<ffffffff810090f1>] ? mwait_idle+0x51/0x70
 [<ffffffff81000796>] ? cpu_idle+0x96/0xb0
Code: 00 00 00 53 48 89 fb 48 8b 7f 58 48 85 ff 74 12 40 f6 c7 01 0f 84 99 00 00 00 48 c7 43 58 00 00 00 00 48 8b 7b 60 48 85 ff 74 0a <f0> ff 0f 0f 94 c0 84 c0 75 6e 48 8b 83 80 00 00 00 48 85 c0 74
RIP  [<ffffffff812437f8>] skb_release_head_state+0x28/0xe0
 RSP <ffff88022fd03c80>
CR2: 00000000a0000000
---[ end trace 6b276feef74ef40b ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: kworker/0:1 Tainted: G      D W   3.1.8-asdf.2.fc16.x86_64 #1
Call Trace:
 <IRQ>  [<ffffffff812cb6f2>] ? panic+0x95/0x18e
 [<ffffffff8100508b>] ? oops_end+0x9b/0xa0
 [<ffffffff812cb01a>] ? no_context+0x1fa/0x209
 [<ffffffff8101e62b>] ? do_page_fault+0x38b/0x430
 [<ffffffff81026229>] ? enqueue_task_fair+0xc9/0xf0
 [<ffffffff810255c8>] ? activate_task+0x48/0x60
 [<ffffffff810253bd>] ? check_preempt_curr+0x6d/0x90
 [<ffffffff81025461>] ? ttwu_do_wakeup+0x11/0x90
 [<ffffffff8102c28b>] ? try_to_wake_up+0xcb/0x270
 [<ffffffff812d0a6f>] ? page_fault+0x1f/0x30
 [<ffffffff812437f8>] ? skb_release_head_state+0x28/0xe0
 [<ffffffff812436e9>] ? __kfree_skb+0x9/0x90
 [<ffffffff812bcf3c>] ? tpacket_rcv+0x10c/0x660
 [<ffffffff810a9cb4>] ? kmem_cache_free+0x14/0x90
 [<ffffffff8124abc3>] ? __netif_receive_skb+0x363/0x400
 [<ffffffff8124dd30>] ? netif_receive_skb+0x70/0x80
 [<ffffffff8124ecab>] ? napi_gro_receive+0x9b/0xb0
 [<ffffffff8124de08>] ? napi_skb_finish+0x38/0x50
 [<ffffffffa005b1f8>] ? e1000_clean_rx_irq+0x278/0x380 [e1000e]
 [<ffffffffa005a9d6>] ? e1000_clean+0x76/0x2c0 [e1000e]
 [<ffffffff8124e631>] ? net_rx_action+0xe1/0x160
 [<ffffffff81035938>] ? __do_softirq+0x98/0x120
 [<ffffffff812d2d6c>] ? call_softirq+0x1c/0x26
 [<ffffffff81003acd>] ? do_softirq+0x4d/0x80
 [<ffffffff8100398c>] ? do_IRQ+0x5c/0xd0
 [<ffffffff812d086b>] ? common_interrupt+0x6b/0x6b
 <EOI>  [<ffffffff812ce930>] ? __schedule+0x230/0x5f0
 [<ffffffff810090f1>] ? mwait_idle+0x51/0x70
 [<ffffffff81000796>] ? cpu_idle+0x96/0xb0
