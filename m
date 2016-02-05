From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Keystone 2 boards boot failure
Date: Fri, 05 Feb 2016 17:18:32 +0100
Message-ID: <2480415.iC3bxkK7OM@wuerfel>
References: <56B0DE61.2000704@ti.com> <1888105.8DsfvU3cAo@wuerfel> <56B37B64.1000606@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Franklin S Cooper Jr." <fcooper@ti.com>, m-karicheri2@ti.com,
	netdev@vger.kernel.org, w-kwok2@ti.com, davem@davemloft.net
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:63674 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbcBEQSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 11:18:45 -0500
In-Reply-To: <56B37B64.1000606@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 February 2016 18:25:08 Grygorii Strashko wrote:
> > 
> > I have another version for testing below. That removes the logic that
> > splits and reassembles the 64-bit values, but leaves the other changes
> > in place. Can you try this?
> > 
> 
> Nop. It crashes kernel

Ah. too bad.

>    50.244448] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [   50.266219] Unable to handle kernel NULL pointer dereference at virtual address 00000001
> [   50.274287] pgd = c0003000
> [   50.277007] [00000001] *pgd=80000800004003, *pmd=00000000
> [   50.282412] Internal error: Oops: a07 [#1] PREEMPT SMP ARM
> [   50.287881] Modules linked in:
> [   50.290938] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.5.0-rc2-00179-gad2f022-dirty #30
> [   50.300214] Hardware name: Keystone
> [   50.303693] task: c07476c0 ti: c0742000 task.ti: c0742000
> [   50.309082] PC is at _test_and_set_bit+0x4/0x4c
> [   50.313607] LR is at __netif_schedule+0x1c/0x60
> [   50.318127] pc : [<c028415c>]    lr : [<c04294f0>]    psr: 20000113
> [   50.318127] sp : c0743d68  ip : 00000001  fp : c0743d7c
> [   50.329568] r10: c0743e00  r9 : c0744100  r8 : ffff9e75
> [   50.334775] r7 : 00000000  r6 : 00000040  r5 : de495b00  r4 : 6d3cdb51
> [   50.341282] r3 : 00000001  r2 : c07476c0  r1 : 6d3cdba9  r0 : 00000000
> [   50.347790] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> [   50.355077] Control: 30c5387d  Table: 1878abc0  DAC: fffffffd
> [   50.360803] Process swapper/0 (pid: 0, stack limit = 0xc0742210)
> [   50.366790] Stack: (0xc0743d68 to 0xc0744000)
> [   50.371137] 3d60:                   d9a16a00 de495b00 c0743d94 c0743d80 c04295a0 c04294e0
> [   50.379291] 3d80: de7a9cc0 de495b00 c0743dbc c0743d98 c037396c c0429570 c0061d34 00000010
> [   50.387445] 3da0: de7a9d80 de7a9d80 00000040 0000012c c0743ddc c0743dc0 c0375f58 c0373848
> [   50.395599] 3dc0: de7a9d80 c0375f3c 00000040 0000012c c0743e3c c0743de0 c042a0cc c0375f48
> [   50.403752] 3de0: c0743e9c c06635f8 c0744b1c c0744b1c c0773c46 1e46b000 c0741000 debac000
> [   50.411907] 3e00: c0743e00 c0743e00 c0743e08 c0743e08 de408000 00000000 c074408c c0742000
> [   50.420061] 3e20: 00000101 00000003 40000003 c0744080 c0743e9c c0743e40 c0026670 c0429ed8
> [   50.428215] 3e40: d8722360 c0744808 00200000 c0744100 ffff9e74 c054088c 0000000a c07779c0
> [   50.436369] 3e60: c073d2c8 c0744080 c0743e40 c0742000 c0744808 c073dddc 0000004e 00000000
> [   50.444522] 3e80: 00000000 de408000 c0773aa4 c07444fc c0743eb4 c0743ea0 c0026a38 c0026548
> [   50.452675] 3ea0: c073dddc 0000004e c0743edc c0743eb8 c0061d34 c00269c4 c0744808 e080400c
> [   50.460828] 3ec0: c0743f08 e0804000 e0805000 c0773aa4 c0743f04 c0743ee0 c0009438 c0061cd8
> [   50.468981] 3ee0: c0010314 60000013 ffffffff c0743f3c c0773aa4 c0773aa4 c0743f64 c0743f08
> [   50.477136] 3f00: c0013a80 c0009404 00000000 deba8348 000070c8 c001f880 c0742000 c07444b0
> [   50.485289] 3f20: c073d324 c0743f78 c0773aa4 c0773aa4 c07444fc c0743f64 c0743f68 c0743f58
> [   50.493442] 3f40: c0010310 c0010314 60000013 ffffffff c006d624 c006a15c c0743f74 c0743f68
> [   50.501595] 3f60: c00598c0 c00102e0 c0743f8c c0743f78 c00599dc c00598a4 00000002 00000000
> [   50.509749] 3f80: c0743fa4 c0743f90 c0538468 c00598d8 c0777050 00000000 c0743ff4 c0743fa8
> [   50.517902] 3fa0: c06fad60 c05383e4 ffffffff ffffffff 00000000 c06fa6d8 ffffffff 00000000
> [   50.526056] 3fc0: 00000000 c0731a30 00000000 c0777294 c0744484 c0731a2c c0748878 80007000
> [   50.534210] 3fe0: 412fc0f4 00000000 00000000 c0743ff8 80008090 c06fa964 00000000 00000000
> [   50.542357] Backtrace: 
> [   50.544816] [<c04294d4>] (__netif_schedule) from [<c04295a0>] (netif_wake_subqueue+0x3c/0x44)
> [   50.553312]  r5:de495b00 r4:d9a16a00
> [   50.556909] [<c0429564>] (netif_wake_subqueue) from [<c037396c>] (netcp_process_tx_compl_packets+0x130/0x134)
> [   50.566789]  r5:de495b00 r4:de7a9cc0
> [   50.570381] [<c037383c>] (netcp_process_tx_compl_packets) from [<c0375f58>] (netcp_tx_poll+0x1c/0x4c)
> [   50.579570]  r7:0000012c r6:00000040 r5:de7a9d80 r4:de7a9d80
> [   50.585258] [<c0375f3c>] (netcp_tx_poll) from [<c042a0cc>] (net_rx_action+0x200/0x2f8)
> [   50.593148]  r7:0000012c r6:00000040 r5:c0375f3c r4:de7a9d80
> [   50.598833] [<c0429ecc>] (net_rx_action) from [<c0026670>] (__do_softirq+0x134/0x258)
> [   50.606637]  r10:c0744080 r9:40000003 r8:00000003 r7:00000101 r6:c0742000 r5:c074408c
> [   50.614486]  r4:00000000
> [   50.617023] [<c002653c>] (__do_softirq) from [<c0026a38>] (irq_exit+0x80/0xb8)
> [   50.624221]  r10:c07444fc r9:c0773aa4 r8:de408000 r7:00000000 r6:00000000 r5:0000004e
> [   50.632069]  r4:c073dddc
> [   50.634608] [<c00269b8>] (irq_exit) from [<c0061d34>] (__handle_domain_irq+0x68/0xbc)
> [   50.642410]  r5:0000004e r4:c073dddc
> [   50.645996] [<c0061ccc>] (__handle_domain_irq) from [<c0009438>] (gic_handle_irq+0x40/0x78)
> 

This is a different bug now, something is corrupting the skb pointer, probably as a
result of the patch below (which is a subset of what is now applied compared
to the last working version):

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 7e291c04a81a..cda19f2401c1 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -117,10 +117,18 @@ static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
+
+static void get_pad_ptr(void **padptr, struct knav_dma_desc *desc)
+{
+	u64 pad64;
+
+	pad64 = le32_to_cpu(desc->pad[0]);
+	*padptr = (void *)(uintptr_t)pad64;
 }
 
 static void get_org_pkt_info(dma_addr_t *buff, u32 *buff_len,

@@ -953,11 +966,11 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 					  unsigned int budget)
 {
 	struct knav_dma_desc *desc;
+	void *ptr;
 	struct sk_buff *skb;
 	unsigned int dma_sz;
 	dma_addr_t dma;
 	int pkts = 0;
-	u32 tmp;
 
 	while (budget--) {
 		dma = knav_queue_pop(netcp->tx_compl_q, &dma_sz);
@@ -970,7 +983,8 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 			continue;
 		}
 
-		get_pad_info((u32 *)&skb, &tmp, desc);
+		get_pad_ptr(&ptr, desc);
+		skb = ptr;
 		netcp_free_tx_desc_chain(netcp, desc, dma_sz);
 		if (!skb) {
 			dev_err(netcp->ndev_dev, "No skb in Tx desc\n");
@@ -1173,7 +1189,8 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 	}
 
 	set_words(&tmp, 1, &desc->packet_info);
-	set_words((u32 *)&skb, 1, &desc->pad[0]);
+	tmp = (uintptr_t)&skb;
+	set_words(&tmp, 1, &desc->pad[0]);
 
 	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
 		tmp = tx_pipe->switch_to_port;


I'm sure it's something obvious and stupid in there, but I just can't
see it and that is very unsatisfying. Do you see where I am going wrong?
Most of all, I want to know it so I don't make the same mistake again
when I patch another driver.

	Arnd
