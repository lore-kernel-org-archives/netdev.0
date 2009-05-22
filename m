From: "Hong H. Pham" <hong.pham@windriver.com>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Thu, 21 May 2009 20:40:06 -0400
Message-ID: <4A15F466.70708@windriver.com>
References: <4A132A0F.8070800@windriver.com>	<20090519.150156.115978100.davem@davemloft.net>	<4A14285C.1040705@windriver.com> <20090521.151841.160383267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060708030200030009010302"
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60253 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754539AbZEVAkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 20:40:12 -0400
In-Reply-To: <20090521.151841.160383267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060708030200030009010302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> There's a bug in your debugging patch:
> 
> +		ld_im0_reg    = LD_IM0(ldn);
> +		ldg_imgmt_reg = LDG_IMGMT(ldn);
> 
> You're reading the register "address", not the register's "value".
> So all of the debugging output is bogus.
> 
> You need to do nr64(ld_im0_reg) and use that as the value, for
> example.
> 
> Can you rerun the test with this fixed?  Thanks!

I don't know how I missed that.. thanks for pointing it out.  Posted
below is a log with the fix.

What's interesting (baffling?) is that interrupts are being received
with the LD interrupt mask set or cleared.  The mask also changes
in between interrupts.  The mask always changes from 3 to 0, and never
from 0 to 3.

Please let me know if there are other tests you would like me to run
to help track this down.
Regards,
Hong

[113570.320487] niu: eth4: Link is up at 10Gb/sec, full duplex
[113576.834042] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: interrupt received while NAPI is in progress
[113576.834066]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113576.834080]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113576.834107] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: interrupt received while NAPI is in progress
[113576.834124]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113576.834137]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113576.834164] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: interrupt received while NAPI is in progress
[113576.834181]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113576.834195]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113576.834222] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: interrupt received while NAPI is in progress
[113576.834239]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113576.834252]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113576.834276] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: interrupt received while NAPI is in progress
[113576.834291]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113576.834303]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113576.834326] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: interrupt received while NAPI is in progress
[113576.834341]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113576.834353]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113576.834374] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: interrupt received while NAPI is in progress
[113576.834389]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113576.834401]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113576.834423] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: interrupt received while NAPI is in progress
[113576.834438]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113576.834450]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113578.311747] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: interrupt received while NAPI is in progress
[113578.311770]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113578.311782]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113578.311805] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: interrupt received while NAPI is in progress
[113578.311821]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113578.311833]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113578.311855] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: interrupt received while NAPI is in progress
[113578.311870]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113578.311882]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113578.311904] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: interrupt received while NAPI is in progress
[113578.311919]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113578.311931]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113578.311952] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: interrupt received while NAPI is in progress
[113578.311968]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113578.311980]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113578.312001] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: interrupt received while NAPI is in progress
[113578.312016]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113578.312028]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113578.312050] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: interrupt received while NAPI is in progress
[113578.312065]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113578.312077]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113578.312098] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: interrupt received while NAPI is in progress
[113578.312114]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113578.312126]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113582.932434] NIU: eth4 CPU=13 LDG=42 rx_vec=0x4000: interrupt received while NAPI is in progress
[113582.932458]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113582.932471]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113582.932499] NIU: eth4 CPU=13 LDG=42 rx_vec=0x4000: interrupt received while NAPI is in progress
[113582.932516]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113582.932529]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113582.932556] NIU: eth4 CPU=13 LDG=42 rx_vec=0x4000: interrupt received while NAPI is in progress
[113582.932571]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113582.932583]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113582.932605] NIU: eth4 CPU=13 LDG=42 rx_vec=0x4000: interrupt received while NAPI is in progress
[113582.932621]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113582.932633]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113582.932655] NIU: eth4 CPU=13 LDG=42 rx_vec=0x4000: interrupt received while NAPI is in progress
[113582.932670]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113582.932682]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113582.932704] NIU: eth4 CPU=13 LDG=42 rx_vec=0x4000: interrupt received while NAPI is in progress
[113582.932719]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113582.932731]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113582.932752] NIU: eth4 CPU=13 LDG=42 rx_vec=0x4000: interrupt received while NAPI is in progress
[113582.932768]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113582.932779]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113582.932801] NIU: eth4 CPU=13 LDG=42 rx_vec=0x4000: interrupt received while NAPI is in progress
[113582.932816]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113582.932828]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113584.656434] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: interrupt received while NAPI is in progress
[113584.656459]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113584.656471]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113584.656525] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: interrupt received while NAPI is in progress
[113584.656542]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113584.656555]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113584.656581] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: interrupt received while NAPI is in progress
[113584.656598]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113584.656612]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113584.656637] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: interrupt received while NAPI is in progress
[113584.656653]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113584.656666]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113584.656689] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: interrupt received while NAPI is in progress
[113584.656705]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113584.656718]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113584.656740] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: interrupt received while NAPI is in progress
[113584.656756]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113584.656768]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113584.656790] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: interrupt received while NAPI is in progress
[113584.656806]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113584.656818]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113584.656840] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: interrupt received while NAPI is in progress
[113584.656856]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113584.656869]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.659480] NIU: eth4 CPU=50 LDG=39 rx_vec=0x0800: interrupt received while NAPI is in progress
[113591.659502]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113591.659514]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.659537] NIU: eth4 CPU=50 LDG=39 rx_vec=0x0800: interrupt received while NAPI is in progress
[113591.659553]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113591.659565]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.659587] NIU: eth4 CPU=50 LDG=39 rx_vec=0x0800: interrupt received while NAPI is in progress
[113591.659602]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113591.659614]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.659636] NIU: eth4 CPU=50 LDG=39 rx_vec=0x0800: interrupt received while NAPI is in progress
[113591.659651]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.659663]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.659685] NIU: eth4 CPU=50 LDG=39 rx_vec=0x0800: interrupt received while NAPI is in progress
[113591.659700]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.659712]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.659734] NIU: eth4 CPU=50 LDG=39 rx_vec=0x0800: interrupt received while NAPI is in progress
[113591.659749]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.659761]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.659783] NIU: eth4 CPU=50 LDG=39 rx_vec=0x0800: interrupt received while NAPI is in progress
[113591.659798]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.659810]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.659832] NIU: eth4 CPU=50 LDG=39 rx_vec=0x0800: interrupt received while NAPI is in progress
[113591.659847]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.659859]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.846419] NIU: eth4 CPU=34 LDG=37 rx_vec=0x0200: interrupt received while NAPI is in progress
[113591.846444]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.846459]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.846489] NIU: eth4 CPU=34 LDG=37 rx_vec=0x0200: interrupt received while NAPI is in progress
[113591.846508]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.846523]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.846551] NIU: eth4 CPU=34 LDG=37 rx_vec=0x0200: interrupt received while NAPI is in progress
[113591.846567]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.846579]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.846602] NIU: eth4 CPU=34 LDG=37 rx_vec=0x0200: interrupt received while NAPI is in progress
[113591.846617]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.846629]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.846651] NIU: eth4 CPU=34 LDG=37 rx_vec=0x0200: interrupt received while NAPI is in progress
[113591.846666]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.846679]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.846700] NIU: eth4 CPU=34 LDG=37 rx_vec=0x0200: interrupt received while NAPI is in progress
[113591.846716]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.846727]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.846750] NIU: eth4 CPU=34 LDG=37 rx_vec=0x0200: interrupt received while NAPI is in progress
[113591.846765]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.846777]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113591.846798] NIU: eth4 CPU=34 LDG=37 rx_vec=0x0200: interrupt received while NAPI is in progress
[113591.846814]   LD_IM0   =0x0000000000000000 [ldf_mask=0x00]
[113591.846826]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113597.471277] NIU: eth4 CPU=42 LDG=38 rx_vec=0x0400: interrupt received while NAPI is in progress
[113597.471302]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113597.471316]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113597.471346] NIU: eth4 CPU=42 LDG=38 rx_vec=0x0400: interrupt received while NAPI is in progress
[113597.471365]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113597.471379]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113597.471408] NIU: eth4 CPU=42 LDG=38 rx_vec=0x0400: interrupt received while NAPI is in progress
[113597.471426]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113597.471440]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113597.471468] NIU: eth4 CPU=42 LDG=38 rx_vec=0x0400: interrupt received while NAPI is in progress
[113597.471484]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113597.471496]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113597.471518] NIU: eth4 CPU=42 LDG=38 rx_vec=0x0400: interrupt received while NAPI is in progress
[113597.471533]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113597.471545]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113597.471567] NIU: eth4 CPU=42 LDG=38 rx_vec=0x0400: interrupt received while NAPI is in progress
[113597.471582]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113597.471594]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113597.471616] NIU: eth4 CPU=42 LDG=38 rx_vec=0x0400: interrupt received while NAPI is in progress
[113597.471631]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113597.471643]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113597.471665] NIU: eth4 CPU=42 LDG=38 rx_vec=0x0400: interrupt received while NAPI is in progress
[113597.471680]   LD_IM0   =0x0000000000000003 [ldf_mask=0x03]
[113597.471692]   LDG_IMGMT=0x0000000000000000 [arm=0x00 timer=0x00]
[113627.656758] BUG: soft lockup - CPU#5 stuck for 61s! [iperf:3055]


--------------060708030200030009010302
Content-Type: text/x-patch;
 name="niu-instrument-ldg-interrupt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="niu-instrument-ldg-interrupt.patch"

---
 drivers/net/niu.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 61 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2b17453..433fced 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4214,8 +4214,67 @@ static void __niu_fastpath_interrupt(struct niu *np, int ldg, u64 v0)
 			niu_txchan_intr(np, rp, ldn);
 	}
 }
 
+// HHP
+static void niu_dump_ldg_irq(struct niu *np, int ldg, u64 v0)
+{
+	static DEFINE_PER_CPU(unsigned long, spurious_count) = { 8 };
+
+	struct niu_parent *parent = np->parent;
+	u64 ld_im0_val, ldg_imgmt_val;
+	u32 rx_vec, tx_vec;
+	int ldn, i;
+
+	if (!__get_cpu_var(spurious_count))
+		return;
+
+	__get_cpu_var(spurious_count)--;
+
+	tx_vec = (v0 >> 32);
+	rx_vec = (v0 & 0xffffffff);
+	printk(KERN_DEBUG "NIU: %s CPU=%i LDG=%i rx_vec=0x%04x: interrupt received while NAPI is in progress\n",
+	       np->dev->name, smp_processor_id(), ldg, rx_vec);
+
+
+	for (i = 0; i < np->num_rx_rings; i++) {
+		struct rx_ring_info *rp = &np->rx_rings[i];
+
+		ldn = LDN_RXDMA(rp->rx_channel);
+		if (parent->ldg_map[ldn] != ldg)
+			continue;
+
+		ld_im0_val    = nr64(LD_IM0(ldn));
+		ldg_imgmt_val = nr64(LDG_IMGMT(ldn));
+		printk(KERN_DEBUG "  LD_IM0   =0x%016lx [ldf_mask=0x%02lx]\n",
+		       (unsigned long)ld_im0_val,
+		       (unsigned long)(ld_im0_val & LD_IM0_MASK)),
+		printk(KERN_DEBUG "  LDG_IMGMT=0x%016lx [arm=0x%02lx timer=0x%02lx]\n",
+		       (unsigned long)ldg_imgmt_val,
+		       (unsigned long)((ldg_imgmt_val & LDG_IMGMT_ARM) >> 31),
+		       (unsigned long)(ldg_imgmt_val & LDG_IMGMT_TIMER));
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
+		ld_im0_val    = LD_IM0(ldn);
+		ldg_imgmt_val = LDG_IMGMT(ldn);
+		printk(KERN_DEBUG "  LD_IM0   =0x%016lx [ldf_mask=0x%02lx]\n",
+		       (unsigned long)ld_im0_val,
+		       (unsigned long)(ld_im0_val & LD_IM0_MASK)),
+		printk(KERN_DEBUG "  LDG_IMGMT=0x%016lx [arm=0x%02lx timer=0x%02lx]\n",
+		       (unsigned long)ldg_imgmt_val,
+		       (unsigned long)((ldg_imgmt_val & LDG_IMGMT_ARM) >> 31),
+		       (unsigned long)(ldg_imgmt_val & LDG_IMGMT_TIMER));
+	}
+}
+
 static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 			      u64 v0, u64 v1, u64 v2)
 {
 	if (likely(napi_schedule_prep(&lp->napi))) {
@@ -4223,9 +4282,10 @@ static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
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

--------------060708030200030009010302--
