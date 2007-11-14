From: Chuck Ebbert <cebbert@redhat.com>
Subject: Null pointer dereference in nf_nat_move_storage(), kernel 2.6.23.1
Date: Wed, 14 Nov 2007 13:03:32 -0500
Message-ID: <473B3874.2020104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Netdev <netdev@vger.kernel.org>
To: netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48499 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbXKNSEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 13:04:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

https://bugzilla.redhat.com/show_bug.cgi?id=259501#c14

BUG: unable to handle kernel NULL pointer dereference at virtual address 0000064 
 printing eip: f8ae1087 
*pde = 39644067
Oops: 0000 [#1] 
SMP 
CPU:    1 
EIP:    0060:[<f8ae1087>]    Not tainted VLI 
EFLAGS: 00010202   (2.6.23.1-21.fc7 #1) 
EIP is at nf_nat_move_storage+0x23/0x69 [nf_nat] 
eax: 00000004   ebx: d73a1bc4   ecx: f8ae1064   edx: d73a1bc0 
esi: d73a1bc0   edi: 00000000   ebp: dfcb6b40   esp: c0786c74 
ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068 
Process swapper (pid: 0, ti=c0786000 task=f7d02c20 task.ti=c18fd000)
Stack:d657fd80 00000001 00000000 f8b61643 00000000 0000004c 00000028 00000000 
00000000 f8b81260 dfcb6b40 f8c0af20 f8b5f7a5 f8b5dd73 c0786cd8 f8ae4180 
130aa8c0 f8ae19dd dfcb6b40 f34b6000 dfcb6b40 00000000 00000001 c0786d14 
Call Trace: 
 [<f8b61643>] __nf_ct_ext_add+0x12f/0x1c4 [nf_conntrack] 
 [<f8b5f7a5>] nf_ct_helper_ext_add+0x9/0x15 [nf_conntrack] 
 [<f8b5dd73>] nf_conntrack_alter_reply+0x73/0x96 [nf_conntrack] 
 [<f8ae19dd>] nf_nat_setup_info+0x3f3/0x54e [nf_nat] 
 [<f8b8d0ea>] ipt_dnat_target+0x0/0x14c [iptable_nat] 
 [<f8b8d22e>] ipt_dnat_target+0x144/0x14c [iptable_nat] 
 [<f8b610fd>] tcp_packet+0xa1c/0xa4b [nf_conntrack] 
 [<c05b4025>] skb_checksum+0x4f/0x29a 
 [<f8b8d0ea>] ipt_dnat_target+0x0/0x14c [iptable_nat] 
 [<f8ae859e>] ipt_do_table+0x3f0/0x482 [ip_tables] 
 [<f8b5dca8>] nf_conntrack_alloc+0x16d/0x1c5 [nf_conntrack] 
 [<f8b603d6>] tcp_new+0xd1/0x1a4 [nf_conntrack] 
 [<f8ae85d3>] ipt_do_table+0x425/0x482 [ip_tables] 
 [<f8b8d257>] nf_nat_rule_find+0x21/0x5c [iptable_nat] 
 [<f8b8d40d>] nf_nat_fn+0x165/0x189 [iptable_nat] 
 [<f8b8d48e>] nf_nat_in+0x29/0x9c [iptable_nat] 
 [<c05d5a9c>] ip_rcv_finish+0x0/0x291 
 [<c05d0ae4>] nf_iterate+0x38/0x6a 
 [<c05d5a9c>] ip_rcv_finish+0x0/0x291 
 [<c05d0c4f>] nf_hook_slow+0x4d/0xb5 
 [<c05d5a9c>] ip_rcv_finish+0x0/0x291 
 [<c05d61a9>] ip_rcv+0x20b/0x4ba 
 [<c05d5a9c>] ip_rcv_finish+0x0/0x291 
 [<c04400dc>] ktime_get_real+0xf/0x2b 
 [<c05b96a8>] netif_receive_skb+0x2e1/0x346 
 [<c04264a0>] __wake_up+0x32/0x43 
 [<f8953358>] e100_poll+0x166/0x2b5 [e100] 
 [<c047cc54>] __slab_free+0x5c/0x216 
 [<c05bb7ec>] net_rx_action+0x9a/0x196 
 [<c0431dfa>] __do_softirq+0x66/0xd3 
 [<c04073e1>] do_softirq+0x6c/0xce 
 [<c04445dd>] tick_do_update_jiffies64+0x93/0xa8 
 [<c045b6b5>] handle_fasteoi_irq+0x0/0xa6 
 [<c0431cbd>] irq_exit+0x38/0x6b 
 [<c04074e2>] do_IRQ+0x9f/0xb9 
 [<c0403ddf>] default_idle+0x0/0x55 
 [<c0405b6f>] common_interrupt+0x23/0x28 
 [<c0403ddf>] default_idle+0x0/0x55 
 [<c042007b>] save_v86_state+0x19/0x12b 
 [<c0421f64>] native_safe_halt+0x2/0x3 
 [<c0403e18>] default_idle+0x39/0x55 
 [<c040340b>] cpu_idle+0xab/0xcc 
 ======================= 
Code: 64 0f fe ff ff 31 c0 c3 57 56 89 d6 53 8b 90 ec 00 00 00 85 d2 74 0f 8a 42
01 84 c0 74 08 0f b6 c0 8d 1c 02 eb 02 31 db 8b 7e 18 <f7> 47 64 80 01 00 00 74
39 b8 40 41 ae f8 e8 fd b7 b3 c7 8b 16 



nf_nat_move_storage():
/usr/src/debug/kernel-2.6.23/linux-2.6.23.i686/net/ipv4/netfilter/nf_nat_core.c:612
      87:       f7 47 64 80 01 00 00    testl  $0x180,0x64(%edi)
      8e:       74 39                   je     c9 <nf_nat_move_storage+0x65>

line 612:
        if (!(ct->status & IPS_NAT_DONE_MASK))
                return;

ct is NULL


