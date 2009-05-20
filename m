From: "Hong H. Pham" <hong.pham@windriver.com>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Wed, 20 May 2009 11:57:16 -0400
Message-ID: <4A14285C.1040705@windriver.com>
References: <1242068453-5124-1-git-send-email-hong.pham@windriver.com>	<20090518.220911.102225532.davem@davemloft.net>	<4A132A0F.8070800@windriver.com> <20090519.150156.115978100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080807060304070400090707"
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59344 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063AbZETP57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2009 11:57:59 -0400
In-Reply-To: <20090519.150156.115978100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080807060304070400090707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I've added the suggested instrumentations to dump out the LD interrupt registers
when spurious interrupts occur.  Attached below is a kernel log.

In all cases, interrupts are being generated even though the LDG has been disarmed!

Regards,
Hong

[502327.615387] niu: eth4: Link is up at 10Gb/sec, full duplex
[502337.835372] NIU: eth4 CPU=42 LDG=38: interrupt received while NAPI is in progress
[502337.835392]   rx_vec=0x0400 LD_IM0[ldf_mask]=0x00
[502337.835404]   LDG_IMGMT=0x0000000000814018 [arm=0x00 timer=0x18]
[502337.835426] NIU: eth4 CPU=42 LDG=38: interrupt received while NAPI is in progress
[502337.835440]   rx_vec=0x0400 LD_IM0[ldf_mask]=0x00
[502337.835451]   LDG_IMGMT=0x0000000000814018 [arm=0x00 timer=0x18]
[502337.835472] NIU: eth4 CPU=42 LDG=38: interrupt received while NAPI is in progress
[502337.835486]   rx_vec=0x0400 LD_IM0[ldf_mask]=0x00
[502337.835498]   LDG_IMGMT=0x0000000000814018 [arm=0x00 timer=0x18]
[502337.835519] NIU: eth4 CPU=42 LDG=38: interrupt received while NAPI is in progress
[502337.835533]   rx_vec=0x0400 LD_IM0[ldf_mask]=0x00
[502337.835544]   LDG_IMGMT=0x0000000000814018 [arm=0x00 timer=0x18]
[502338.215733] NIU: eth4 CPU=5 LDG=41: interrupt received while NAPI is in progress
[502338.215753]   rx_vec=0x2000 LD_IM0[ldf_mask]=0x00
[502338.215765]   LDG_IMGMT=0x000000000081a018 [arm=0x00 timer=0x18]
[502338.215789] NIU: eth4 CPU=5 LDG=41: interrupt received while NAPI is in progress
[502338.215803]   rx_vec=0x2000 LD_IM0[ldf_mask]=0x00
[502338.215814]   LDG_IMGMT=0x000000000081a018 [arm=0x00 timer=0x18]
[502338.215835] NIU: eth4 CPU=5 LDG=41: interrupt received while NAPI is in progress
[502338.215849]   rx_vec=0x2000 LD_IM0[ldf_mask]=0x00
[502338.215860]   LDG_IMGMT=0x000000000081a018 [arm=0x00 timer=0x18]
[502338.215881] NIU: eth4 CPU=5 LDG=41: interrupt received while NAPI is in progress
[502338.215895]   rx_vec=0x2000 LD_IM0[ldf_mask]=0x00
[502338.215906]   LDG_IMGMT=0x000000000081a018 [arm=0x00 timer=0x18]
[502385.547793] BUG: soft lockup - CPU#5 stuck for 61s! [iperf:3070]
[502385.547809] Modules linked in:
[502385.547829] TSTATE: 0000000080001602 TPC: 00000000004a8bb8 TNPC: 00000000004a8bbc Y: 00000000    Not tainted
[502385.547867] TPC: <handle_IRQ_event+0x18/0x120>
[502385.547881] g0: fffff803fb741ec0 g1: 0000000000000000 g2: 0000000000000000 g3: 0000000000010103
[502385.547898] g4: fffff803f3ad3840 g5: fffff803fed9a000 g6: fffff803f3b28000 g7: 000000000000000f
[502385.547914] o0: 0000000000000001 o1: 0000000000000001 o2: fffff803fa8909e4 o3: 0000000000000000
[502385.547931] o4: 000000000000004f o5: 00000000000000a4 sp: fffff803ff6535c1 ret_pc: 00000000007794e8
[502385.547951] RPC: <_spin_unlock+0x28/0x40>
[502385.547963] l0: 0000000000000001 l1: 0000000000000018 l2: 0000000000000018 l3: 0000000000835848
[502385.547980] l4: 0000000000007ba2 l5: 0000000000008001 l6: 0000000000924090 l7: 0000000000936000
[502385.547997] i0: 0000000000000018 i1: fffff803f5a60c00 i2: 0000000000000001 i3: 0000000000000000
[502385.548013] i4: 0000000000000000 i5: fffff803fed72000 i6: fffff803ff653681 i7: 00000000004aab74
[502385.548036] I7: <handle_fasteoi_irq+0x74/0x100>
[502385.548946] BUG: soft lockup - CPU#42 stuck for 61s! [iperf:3056]
[502385.548958] Modules linked in:
[502385.548976] TSTATE: 0000004480001606 TPC: 00000000007793f8 TNPC: 00000000007793fc Y: 00000000    Not tainted
[502385.549012] TPC: <_spin_unlock_irqrestore+0x38/0x60>
[502385.549026] g0: 0000000000001000 g1: 0000000000000000 g2: 0000000000000000 g3: 000000000abffc30
[502385.549045] g4: fffff803f3a40000 g5: fffff803feec2000 g6: fffff803f3a0c000 g7: 000000000000000c
[502385.549062] o0: 00000000000001a8 o1: 0000000038ac8a43 o2: 000000008716e61f o3: 00000000c6db4f40
[502385.549080] o4: 000000000098f658 o5: 000000004cd739c3 sp: fffff803ff52b421 ret_pc: 00000000005d7630
[502385.549105] RPC: <mix_pool_bytes_extract+0x170/0x180>
[502385.549119] l0: 000000000000006a l1: 000000000000007f l2: 0000000095961289 l3: 0000000000000019
[502385.549135] l4: 0000000000000033 l5: 000000000000004c l6: 0000000000000067 l7: 0000000000000001
[502385.549152] i0: 00000000008b7d98 i1: 0000000000000000 i2: fffff803ff52bdb0 i3: 0000000000000000
[502385.549168] i4: 00000000007923b8 i5: 0000000000000020 i6: fffff803ff52b4e1 i7: 00000000005d87d8
[502385.549188] I7: <add_timer_randomness+0xb8/0x200>


David Miller wrote:
> From: "Hong H. Pham" <hong.pham@windriver.com>
> Date: Tue, 19 May 2009 17:52:15 -0400
> 
>> Unfortunately I don't have a PCIe NIU card to test in an x86 box.
>> If the hang does not happen on x86 (which is my suspicion), that
>> would rule out a problem with the NIU chip.  That would mean there's
>> some interaction between the NIU and sun4v hypervisor that's causing
>> the spurious interrupts.
> 
> I am still leaning towards the NIU chip, or our programming of
> it, as causing this behavior.
> 
> Although it's possible that the interrupt logic inside of
> Niagara-T2, or how it's hooked up to the internal NIU ASIC
> inside of the CPU, might be to blame I don't consider it likely
> given the basic gist of the behavior you see.
> 
> To quote section 17.3.2 of the UltraSPARC-T2 manual:
> 
> 	An interrupt will only be issued if the timer is zero,
> 	the arm bit is set, and one of more LD's in the LDG, have
> 	their flags set and not masked.
> 
> which confirms our understanding of how this should work.
> 
> Can you test something Hong?  Simply trigger the hung case
> and when it happens read the LDG registers to see if the ARM
> bit is set, and what the LDG mask bits say.
> 
> There might be a bug somewhere that causes us to call
> niu_ldg_rearm() improperly.  In particular I'm looking
> at that test done in niu_interrupt():
> 
> 	if (likely(v0 & ~((u64)1 << LDN_MIF)))
> 		niu_schedule_napi(np, lp, v0, v1, v2);
> 	else
> 		niu_ldg_rearm(np, lp, 1);
> 
> If we call niu_ldg_rearm() on an LDG being serviced by NAPI
> before that poll sequence calls napi_complete() we could
> definitely see this weird behavior.  And whatever causes
> that would be the bug to fix.
> 
> Thanks!
> 
>  

--------------080807060304070400090707
Content-Type: text/plain;
 name="niu-instrument-ldg-interrupt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="niu-instrument-ldg-interrupt.patch"

---
 drivers/net/niu.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 60 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2b17453..a40653e 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4210,26 +4210,85 @@ static void __niu_fastpath_interrupt(struct niu *np, int ldg, u64 v0)
 			continue;
 
 		nw64(LD_IM0(ldn), LD_IM0_MASK);
 		if (tx_vec & (1 << rp->tx_channel))
 			niu_txchan_intr(np, rp, ldn);
 	}
 }
 
+// HHP
+static void niu_dump_ldg_irq(struct niu *np, int ldg, u64 v0)
+{
+	static DEFINE_PER_CPU(unsigned long, spurious_count) = { 4 };
+
+	struct niu_parent *parent = np->parent;
+	u64 ld_im0_reg, ldg_imgmt_reg;
+	u32 rx_vec, tx_vec;
+	int ldn, i;
+
+	if (!__get_cpu_var(spurious_count))
+		return;
+
+	__get_cpu_var(spurious_count)--;
+	printk(KERN_DEBUG "NIU: %s CPU=%i LDG=%i: interrupt received while NAPI is in progress\n",
+	       np->dev->name, smp_processor_id(), ldg);
+
+	tx_vec = (v0 >> 32);
+	rx_vec = (v0 & 0xffffffff);
+
+	for (i = 0; i < np->num_rx_rings; i++) {
+		struct rx_ring_info *rp = &np->rx_rings[i];
+
+		ldn = LDN_RXDMA(rp->rx_channel);
+		if (parent->ldg_map[ldn] != ldg)
+			continue;
+
+		ld_im0_reg    = LD_IM0(ldn);
+		ldg_imgmt_reg = LDG_IMGMT(ldn);
+		printk(KERN_DEBUG "  rx_vec=0x%04x LD_IM0[ldf_mask]=0x%02lx\n",
+		       rx_vec,
+		       (unsigned long)(ld_im0_reg & LD_IM0_MASK)),
+		printk(KERN_DEBUG "  LDG_IMGMT=0x%016lx [arm=0x%02lx timer=0x%02lx]\n",
+		       (unsigned long)ldg_imgmt_reg,
+		       (unsigned long)((ldg_imgmt_reg & LDG_IMGMT_ARM) >> 31),
+		       (unsigned long)(ldg_imgmt_reg & LDG_IMGMT_TIMER));
+	}
+
+	/* Spurious TX interrupts should not happen */
+	for (i = 0; i < np->num_tx_rings; i++) {
+		struct tx_ring_info *rp = &np->tx_rings[i];
+		ldn = LDN_TXDMA(rp->tx_channel);
+
+		if (parent->ldg_map[ldn] != ldg)
+			continue;
+
+		ld_im0_reg    = LD_IM0(ldn);
+		ldg_imgmt_reg = LDG_IMGMT(ldn);
+		printk(KERN_DEBUG "  tx_vec=0x%04x LD_IM0[ldf_mask]=0x%02lx\n",
+		       tx_vec,
+		       (unsigned long)(ld_im0_reg & LD_IM0_MASK)),
+		printk(KERN_DEBUG "  LDG_IMGMT=0x%016lx [arm=0x%02lx timer=0x%02lx]\n",
+		       (unsigned long)ldg_imgmt_reg,
+		       (unsigned long)((ldg_imgmt_reg & LDG_IMGMT_ARM) >> 31),
+		       (unsigned long)(ldg_imgmt_reg & LDG_IMGMT_TIMER));
+	}
+}
+
 static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 			      u64 v0, u64 v1, u64 v2)
 {
 	if (likely(napi_schedule_prep(&lp->napi))) {
 		lp->v0 = v0;
 		lp->v1 = v1;
 		lp->v2 = v2;
 		__niu_fastpath_interrupt(np, lp->ldg_num, v0);
 		__napi_schedule(&lp->napi);
-	}
+	} else
+		niu_dump_ldg_irq(np, lp->ldg_num, v0);
 }
 
 static irqreturn_t niu_interrupt(int irq, void *dev_id)
 {
 	struct niu_ldg *lp = dev_id;
 	struct niu *np = lp->np;
 	int ldg = lp->ldg_num;
 	unsigned long flags;

--------------080807060304070400090707--
