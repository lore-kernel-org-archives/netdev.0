From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: Oops in xfrm_bundle_ok
Date: Thu, 05 Jul 2007 02:47:10 +0900 (JST)
Message-ID: <20070705.024710.74752219.chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm05mta.dion.ne.jp ([219.125.112.10]:1470 "HELO
	nm05omta059.dion.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754418AbXGDRrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 13:47:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello,

I got Oops like below. I glanced xfrm_bundle_ok() in
xfrm_policy.c and __xfrm4.bundle_create() in xfrm4_policy.c.
In __xfrm4.bundle_create(), xfrm_dst->next may be null but
in xfrm_bundle_ok(), later loop does not check null, only break
`if (last == first)'.

I tried to solve with only checking null but could not fix. Would
someone fix this, please.

----

BUG: unable to handle kernel NULL pointer dereference at virtual address 00000100
 printing eip:
c035b5eb
*pde = 00000000
Oops: 0002 [#1]
Modules linked in: cls_u32 sch_sfq sch_htb netconsole nfs tun xt_policy xt_MARK ipt_MASQUERADE xt_conntrack xt_mark ipt_REJECT ipt_recent xt_state iptable_filter twofish twofish_common camellia serpent blowfish xcbc sha256 crypto_null dm_snapshot dm_mod floppy rng_core evdev
CPU:    0
EIP:    0060:[<c035b5eb>]    Not tainted VLI
EFLAGS: 00010202   (2.6.22-rc7-git3 #2)
EIP is at xfrm_bundle_ok+0x2bb/0x2f0
eax: 00000000   ebx: d40f23c0   ecx: 00000000   edx: 00000596
esi: d40bb618   edi: d40f23c0   ebp: d40f22a0   esp: c04b3be8
ds: 007b   es: 007b   fs: 0000  gs: 0000  ss: 0068
Process swapper (pid: 0, ti=c04b2000 task=c0480280 task.ti=c04b2000)
Stack: 00000000 c04b3d20 c04b3d3c d514b738 066f4a9e 00000286 d57a2000 00000000 
       d514b6cc d40f22a0 c04b3d20 d57a2000 00000000 c035950e 00000002 00000000 
       00000002 00000003 d57a2000 c035bdf2 c035d6d0 c04b3d5c f517a92c 464702d0 
Call Trace:
 [<c035950e>] __xfrm4_find_bundle+0x6e/0x90
 [<c035bdf2>] __xfrm_lookup+0xd2/0x6f0
 [<c035d6d0>] xfrm_policy_lookup+0x0/0xa0
 [<c030daf0>] ip_route_output_flow+0x60/0x250
 [<c030dcf1>] ip_route_output_key+0x11/0x20
 [<c0347218>] ipgre_tunnel_xmit+0x118/0x980
 [<c0302729>] nf_conntrack_in+0x249/0x4e0
 [<c034efe7>] ipt_do_table+0x207/0x340
 [<c02e8edd>] dev_hard_start_xmit+0x1cd/0x230
 [<c02eab02>] dev_queue_xmit+0x202/0x260
 [<c03149d0>] ip_finish_output+0x0/0x2a0
 [<c031642d>] ip_output+0x22d/0x300
 [<c03149d0>] ip_finish_output+0x0/0x2a0
 [<c0313220>] dst_output+0x0/0x10
 [<c0313220>] dst_output+0x0/0x10
 [<c0315888>] ip_queue_xmit+0x1d8/0x3f0
 [<c0313220>] dst_output+0x0/0x10
 [<c032bd53>] tcp_v4_send_check+0x43/0xf0
 [<c0325db9>] tcp_transmit_skb+0x409/0x7f0
 [<c032d96b>] tcp_v4_rcv+0x7bb/0x910
 [<c02ff9c9>] nf_hook_slow+0x59/0xe0
 [<c0327047>] tcp_retransmit_skb+0x507/0x600
 [<c031f359>] tcp_enter_loss+0x69/0x270
 [<c0329585>] tcp_write_timer+0x2f5/0x660
 [<c0329290>] tcp_write_timer+0x0/0x660
 [<c0121f01>] run_timer_softirq+0x101/0x150
 [<c0130fdf>] tick_handle_periodic+0xf/0x70
 [<c011ed92>] __do_softirq+0x42/0x90
 [<c011ee06>] do_softirq+0x26/0x30
 [<c0105d74>] do_IRQ+0x44/0x80
 [<c010488b>] common_interrupt+0x23/0x28
 [<c025b5a5>] acpi_processor_idle+0x1d2/0x36d
 [<c01023de>] cpu_idle+0x3e/0x60
 [<c04b4b2f>] start_kernel+0x20f/0x260
 [<c04b4470>] unknown_bootoption+0x0/0x250
 =======================
Code: 87 84 00 00 00 39 c2 0f 84 53 ff ff ff 85 d2 0f 84 4b ff ff ff 85 c0 0f 84 43 ff ff ff 8d 76 00 e9 9b fd ff ff 8b 07 89 44 24 1c <89> 90 00 01 00 00 8b 4c 24 1c 8b 41 68 e8 43 2d 00 00 89 c2 8b 
EIP: [<c035b5eb>] xfrm_bundle_ok+0x2bb/0x2f0 SS:ESP 0068:c04b3be8
Kernel panic - not syncing: Fatal exception in interrupt


