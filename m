From: Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] net: sk == 0xffffffff fix - not for commit
Date: Mon, 09 Dec 2013 12:47:52 +0100
Message-ID: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Marek Szyprowski <m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

NOT FOR COMMITTING TO MAINLINE.

With g_ether loaded the sk occasionally becomes 0xffffffff.
It happens usually after transferring few hundreds of kilobytes to few
tens of megabytes. If sk is 0xffffffff then dereferencing it causes
kernel panic.

This is a *workaround*. I don't know enough net code to understand the core
of the problem. However, with this patch applied the problems are gone,
or at least pushed farther away.

The relevant stack trace below:

[   53.583351] Unable to handle kernel NULL pointer dereference at virtual address 00000011                                                                                                         ]
[   53.590077] pgd = c0004000
[   53.592761] [00000011] *pgd=00000000
[   53.596319] Internal error: Oops: 17 [#1] PREEMPT ARM
[   53.601223] Modules linked in: usb_f_ecm g_ether u_ether libcomposite
[   53.607641] CPU: 0 PID: 0 Comm: swapper Not tainted 3.12.0-rc6+ #157
[   53.613962] task: c058e5d8 ti: c0584000 task.ti: c0584000
[   53.619345] PC is at tcp_v4_early_demux+0xbc/0x150
[   53.624105] LR is at __inet_lookup_established+0x25c/0x2e0
[   53.629562] pc : [<c03595a4>]    lr : [<c033fc0c>]    psr: a0000113
[   53.629562] sp : c0585d08  ip : c0585cd0  fp : c0585d2c
[   53.640997] r10: c058cf84  r9 : c05c1768  r8 : e7b22740
[   53.646197] r7 : 00000000  r6 : 00002cb7  r5 : ffffffff  r4 : e7b22740
[   53.652697] r3 : c0304504  r2 : c0585cb8  r1 : e6d3e070  r0 : ffffffff
[   53.659198] Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[   53.666476] Control: 10c5387d  Table: 57b48019  DAC: 00000015
[   53.672194] Process swapper (pid: 0, stack limit = 0xc0584238)
[   53.678001] Stack: (0xc0585d08 to 0xc0586000)
[   53.682338] 5d00:                   0381a8c0 0000eb89 00000002 c0585d20 e7b6e810 e7b22758
[   53.690484] 5d20: c0585d5c c0585d30 c03377f0 c03594f4 c00104e8 c0028ef4 c058cf70 c058ddec
[   53.698629] 5d40: 00000008 e7806000 00000000 e7b22740 c0585dac c0585d60 c0311dd4 c0337480
[   53.706775] 5d60: c058cf78 00000000 60000113 ffffffff c0585dfc e7b22740 c0014368 c058cf84
[   53.714921] 5d80: 00000000 e7b22740 00000000 c05c8b14 00000002 c05c8b60 00000000 00100100
[   53.723067] 5da0: c0585dc4 c0585db0 c0312f8c c0311c20 e7b22740 00000000 c0585dfc c0585dc8
[   53.731212] 5dc0: c031390c c0312f60 00200200 c05c8b44 00000000 c05c8b60 0000000c 0000012a
[   53.739358] 5de0: c05c8b00 c059c548 00000001 00000040 c0585e3c c0585e00 c031331c c0313874
[   53.747503] 5e00: c05c8ce3 c0584000 c05ca6c0 ffff3f7c c0028504 00000003 0000000c c05ceb10
[   53.755650] 5e20: c05ceb0c 00000001 c0584000 c0584000 c0585ea4 c0585e40 c0028968 c0313238
[   53.763795] 5e40: c005cc94 c005eb24 00200000 c059b3e0 ffff3f7b c059c548 c05ceac0 0000000a
[   53.771941] 5e60: 00000000 c059e6d8 c0584000 0000000c 00000101 c05c8d70 00000000 60000193
[   53.780086] 5e80: c0584000 00000000 c0619b00 00000000 412fc082 c0584038 c0585ebc c0585ea8
[   53.788232] 5ea0: c0028c40 c0028814 00000000 c0584000 c0585ed4 c0585ec0 c0028fb8 c0028bd0
[   53.796378] 5ec0: c05b5018 00000058 c0585ef4 c0585ed8 c00104e8 c0028ef4 00000020 c0619b28
[   53.804524] 5ee0: c0585f20 00000001 c0585f1c c0585ef8 c00085dc c00104a8 c058c734 c00106d4
[   53.812670] 5f00: 60000013 ffffffff c0585f54 c058c0d0 c0585f74 c0585f20 c0014344 c0008578
[   53.820815] 5f20: 00000000 00002a9c 00000000 c058c734 c0584038 c05c92ac c0584000 c05c8c08
[   53.828961] 5f40: c058c0d0 412fc082 c0584038 c0585f74 c0585f68 c0585f68 c00106d0 c00106d4
[   53.837107] 5f60: 60000013 ffffffff c0585f9c c0585f78 c005c2ac c00106ac c058c040 c0584000
[   53.845252] 5f80: c0584000 c0584000 c03aa868 ffffffff c0585fb4 c0585fa0 c03a2458 c005c198
[   53.853398] 5fa0: 00000000 c058ca08 c0585ff4 c0585fb8 c053aa74 c03a23d0 ffffffff ffffffff
[   53.861544] 5fc0: c053a540 00000000 00000000 c0566058 00000000 10c53c7d c058c05c c0566054
[   53.869689] 5fe0: c058f88c 30004059 00000000 c0585ff8 30008070 c053a7c8 00000000 00000000
[   53.877848] [<c03595a4>] (tcp_v4_early_demux+0xbc/0x150) from [<c03377f0>] (ip_rcv+0x37c/0x590)
[   53.886510] [<c03377f0>] (ip_rcv+0x37c/0x590) from [<c0311dd4>] (__netif_receive_skb_core+0x1c0/0x624)
[   53.895779] [<c0311dd4>] (__netif_receive_skb_core+0x1c0/0x624) from [<c0312f8c>] (__netif_receive_skb+0x38/0x88)
[   53.906003] [<c0312f8c>] (__netif_receive_skb+0x38/0x88) from [<c031390c>] (process_backlog+0xa4/0x15c)
[   53.915361] [<c031390c>] (process_backlog+0xa4/0x15c) from [<c031331c>] (net_rx_action+0xf0/0x230)
[   53.924290] [<c031331c>] (net_rx_action+0xf0/0x230) from [<c0028968>] (__do_softirq+0x160/0x35c)
[   53.933040] [<c0028968>] (__do_softirq+0x160/0x35c) from [<c0028c40>] (do_softirq+0x7c/0x80)
[   53.941444] [<c0028c40>] (do_softirq+0x7c/0x80) from [<c0028fb8>] (irq_exit+0xd0/0x10c)
[   53.949423] [<c0028fb8>] (irq_exit+0xd0/0x10c) from [<c00104e8>] (handle_IRQ+0x4c/0x94)
[   53.957390] [<c00104e8>] (handle_IRQ+0x4c/0x94) from [<c00085dc>] (vic_handle_irq+0x70/0xac)
[   53.965795] [<c00085dc>] (vic_handle_irq+0x70/0xac) from [<c0014344>] (__irq_svc+0x44/0x78)
[   53.974106] Exception stack(0xc0585f20 to 0xc0585f68)
[   53.979137] 5f20: 00000000 00002a9c 00000000 c058c734 c0584038 c05c92ac c0584000 c05c8c08
[   53.987283] 5f40: c058c0d0 412fc082 c0584038 c0585f74 c0585f68 c0585f68 c00106d0 c00106d4
[   53.995423] 5f60: 60000013 ffffffff
[   53.998898] [<c0014344>] (__irq_svc+0x44/0x78) from [<c00106d4>] (arch_cpu_idle+0x34/0x40)
[   54.007133] [<c00106d4>] (arch_cpu_idle+0x34/0x40) from [<c005c2ac>] (cpu_startup_entry+0x120/0x26c)
[   54.016236] [<c005c2ac>] (cpu_startup_entry+0x120/0x26c) from [<c03a2458>] (rest_init+0x94/0x98)
[   54.024992] [<c03a2458>] (rest_init+0x94/0x98) from [<c053aa74>] (start_kernel+0x2b8/0x2c4)
[   54.033299] Code: e3043504 e5845010 e34c3030 e5843064 (e5d53012)

Signed-off-by: Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b14266b..c6a318f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1868,7 +1868,7 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 				       iph->saddr, th->source,
 				       iph->daddr, ntohs(th->dest),
 				       skb->skb_iif);
-	if (sk) {
+	if (!IS_ERR_OR_NULL(sk)) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
 		if (sk->sk_state != TCP_TIME_WAIT) {
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
