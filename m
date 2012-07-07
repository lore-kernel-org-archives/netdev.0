From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: [PATCH v2] bridge: netfilter: fix skb->nf_bridge NULL panic in
 br_nf_forward_finish
Date: Sat, 07 Jul 2012 18:00:23 +0800
Message-ID: <1341655223.7993.3.camel@chief-river-32>
References: <1341622087.4004.2.camel@chief-river-32>
	 <alpine.LFD.2.00.1207071229010.1595@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:44405 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab2GGKBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 06:01:36 -0400
In-Reply-To: <alpine.LFD.2.00.1207071229010.1595@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-07 at 12:48 +0300, Julian Anastasov wrote:
> 
> 	Very good. Thanks for tracking and fixing this bug.
> Can you send a copy to Simon Horman <horms@verge.net.au>
> with correct Subject. As this change can go to stable
> kernels you can also improve the comments, for example:
> 
> ipvs: fix oops on NAT reply in br_nf context
> 
> 	IPVS should not reset skb->nf_bridge in FORWARD hook
> by calling nf_reset for NAT replies. It triggers oops in
> br_nf_forward_finish.
> 
> [here follows your corrected description including
> the stack trace]

How about below? Can I have your ACK?
I'll resend this patch in another mail.
===

Subject: [PATCH] ipvs: fix oops on NAT reply in br_nf context

IPVS should not reset skb->nf_bridge in FORWARD hook
by calling nf_reset for NAT replies. It triggers oops in
br_nf_forward_finish.

[  579.781508] BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
[  579.781669] IP: [<ffffffff817b1ca5>] br_nf_forward_finish+0x58/0x112
[  579.781792] PGD 218f9067 PUD 0 
[  579.781865] Oops: 0000 [#1] SMP 
[  579.781945] CPU 0 
[  579.781983] Modules linked in:
[  579.782047] 
[  579.782080] 
[  579.782114] Pid: 4644, comm: qemu Tainted: G        W    3.5.0-rc5-00006-g95e69f9 #282 Hewlett-Packard  /30E8
[  579.782300] RIP: 0010:[<ffffffff817b1ca5>]  [<ffffffff817b1ca5>] br_nf_forward_finish+0x58/0x112
[  579.782455] RSP: 0018:ffff88007b003a98  EFLAGS: 00010287
[  579.782541] RAX: 0000000000000008 RBX: ffff8800762ead00 RCX: 000000000001670a
[  579.782653] RDX: 0000000000000000 RSI: 000000000000000a RDI: ffff8800762ead00
[  579.782845] RBP: ffff88007b003ac8 R08: 0000000000016630 R09: ffff88007b003a90
[  579.782957] R10: ffff88007b0038e8 R11: ffff88002da37540 R12: ffff88002da01a02
[  579.783066] R13: ffff88002da01a80 R14: ffff88002d83c000 R15: ffff88002d82a000
[  579.783177] FS:  0000000000000000(0000) GS:ffff88007b000000(0063) knlGS:00000000f62d1b70
[  579.783306] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  579.783395] CR2: 0000000000000004 CR3: 00000000218fe000 CR4: 00000000000027f0
[  579.783505] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  579.783684] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  579.783795] Process qemu (pid: 4644, threadinfo ffff880021b20000, task ffff880021aba760)
[  579.783919] Stack:
[  579.783959]  ffff88007693cedc ffff8800762ead00 ffff88002da01a02 ffff8800762ead00
[  579.784110]  ffff88002da01a02 ffff88002da01a80 ffff88007b003b18 ffffffff817b26c7
[  579.784260]  ffff880080000000 ffffffff81ef59f0 ffff8800762ead00 ffffffff81ef58b0
[  579.784477] Call Trace:
[  579.784523]  <IRQ> 
[  579.784562] 
[  579.784603]  [<ffffffff817b26c7>] br_nf_forward_ip+0x275/0x2c8
[  579.784707]  [<ffffffff81704b58>] nf_iterate+0x47/0x7d
[  579.784797]  [<ffffffff817ac32e>] ? br_dev_queue_push_xmit+0xae/0xae
[  579.784906]  [<ffffffff81704bfb>] nf_hook_slow+0x6d/0x102
[  579.784995]  [<ffffffff817ac32e>] ? br_dev_queue_push_xmit+0xae/0xae
[  579.785175]  [<ffffffff8187fa95>] ? _raw_write_unlock_bh+0x19/0x1b
[  579.785179]  [<ffffffff817ac417>] __br_forward+0x97/0xa2
[  579.785179]  [<ffffffff817ad366>] br_handle_frame_finish+0x1a6/0x257
[  579.785179]  [<ffffffff817b2386>] br_nf_pre_routing_finish+0x26d/0x2cb
[  579.785179]  [<ffffffff817b2cf0>] br_nf_pre_routing+0x55d/0x5c1
[  579.785179]  [<ffffffff81704b58>] nf_iterate+0x47/0x7d
[  579.785179]  [<ffffffff817ad1c0>] ? br_handle_local_finish+0x44/0x44
[  579.785179]  [<ffffffff81704bfb>] nf_hook_slow+0x6d/0x102
[  579.785179]  [<ffffffff817ad1c0>] ? br_handle_local_finish+0x44/0x44
[  579.785179]  [<ffffffff81551525>] ? sky2_poll+0xb35/0xb54
[  579.785179]  [<ffffffff817ad62a>] br_handle_frame+0x213/0x229
[  579.785179]  [<ffffffff817ad417>] ? br_handle_frame_finish+0x257/0x257
[  579.785179]  [<ffffffff816e3b47>] __netif_receive_skb+0x2b4/0x3f1
[  579.785179]  [<ffffffff816e69fc>] process_backlog+0x99/0x1e2
[  579.785179]  [<ffffffff816e6800>] net_rx_action+0xdf/0x242
[  579.785179]  [<ffffffff8107e8a8>] __do_softirq+0xc1/0x1e0
[  579.785179]  [<ffffffff8135a5ba>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  579.785179]  [<ffffffff8188812c>] call_softirq+0x1c/0x30

The steps to reproduce as follow,

1. On Host1, setup brige br0(192.168.1.106)
2. Boot a kvm guest(192.168.1.105) on Host1 and start httpd
3. Start IPVS service on Host1
   ipvsadm -A -t 192.168.1.106:80 -s rr
   ipvsadm -a -t 192.168.1.106:80 -r 192.168.1.105:80 -m
4. Run apache benchmark on Host2(192.168.1.101)
   ab -n 1000 http://192.168.1.106/

ip_vs_reply4
  ip_vs_out
    handle_response
      ip_vs_notrack
        nf_reset()
        {
          skb->nf_bridge = NULL;
        }

Actually, IPVS wants in this case just to replace nfct
with untracked version. So replace the nf_reset(skb) call
in ip_vs_notrack() with a nf_conntrack_put(skb->nfct) call.

Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>
---
 include/net/ip_vs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d6146b4..95374d1 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1425,7 +1425,7 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 	if (!ct || !nf_ct_is_untracked(ct)) {
-		nf_reset(skb);
+		nf_conntrack_put(skb->nfct);
 		skb->nfct = &nf_ct_untracked_get()->ct_general;
 		skb->nfctinfo = IP_CT_NEW;
 		nf_conntrack_get(skb->nfct);
