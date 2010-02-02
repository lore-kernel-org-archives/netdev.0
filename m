From: Patrick McHardy <kaber@trash.net>
Subject: Re: IP: Send an ICMP "Fragment Reassembly Timeout" message when	enabling
 connection track
Date: Tue, 02 Feb 2010 17:46:55 +0100
Message-ID: <4B6856FF.3050904@trash.net>
References: <20100202162228.GC4305@wear.picochip.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090606070808010404090303"
Cc: netdev@vger.kernel.org, shanwei@cn.fujitsu.com
To: Jamie Iles <jamie.iles@picochip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33754 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab0BBQq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 11:46:59 -0500
In-Reply-To: <20100202162228.GC4305@wear.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090606070808010404090303
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Jamie Iles wrote:
> Hi,
> 
> I have an ARM based board that I'm running off of today's next tree. When
> booting with a rootfs over NFS I regularly see a crash with the following log:
> 
> huh, entered c0237b8c with preempt_count 00000103, exited with 00000102?
> kernel BUG at kernel/timer.c:1035!
> Unable to handle kernel NULL pointer dereference at virtual address 00000000
> pgd = c0004000
> [00000000] *pgd=00000000
> Internal error: Oops: 817 [#1] PREEMPT
> last sysfs file: /sys/class/mtd/mtd6ro/dev
> Modules linked in:
> CPU: 0    Not tainted  (2.6.33-rc6-next-20100202-picochip-arm2009q3+ #46)
> PC is at __bug+0x18/0x24
> LR is at __bug+0x14/0x24
> pc : [<c0024240>]    lr : [<c002423c>]    psr: 60000113
> sp : c03a3ec8  ip : c03cb880  fp : c03ef9c8
> r10: c03efdc8  r9 : c03efbc8  r8 : c03effc8
> r7 : c7e171b4  r6 : c03ef1a0  r5 : c03a2000  r4 : 00000000
> r3 : 00000000  r2 : c03a3ebc  r1 : c033ae76  r0 : 00000029
> Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> Control: 00c5387d  Table: 07e58008  DAC: 00000017
> Process swapper (pid: 0, stack limit = 0xc03a2268)
> Stack: (0xc03a3ec8 to 0xc03a4000)
> 3ec0:                   00000000 c0046a54 00000002 00000000 c00468d8 00000000
> 3ee0: 00000000 00000103 c7e17180 c0237b8c 00000002 c095601c 00000000 c036c3df
> 3f00: c03a3f00 c03a3f00 00000000 00000000 c03a2000 00000004 c03ef004 00000103
> 3f20: 0000000a 00000101 00000001 c003fdf4 c03ad92c 00000000 c03a73c0 00000000
> 3f40: 00000024 c03a2000 00000000 00000010 00000002 00000001 c03a2000 0001bf40
> 3f60: 00000000 c003ff64 00000024 c0020070 ffffffff fe060000 00000010 c02a6170
> 3f80: c0021a70 00000000 00000000 c03a2000 c03a2000 c001d3bc c001d3b8 c03a6a18
> 3fa0: 0001bfa8 410fb767 0001bf40 00000000 c03a73e8 c03a3fc8 c0021a70 c0021a74
> 3fc0: 60000013 ffffffff c03a2000 c0021f40 c094b0e8 c0008920 c0008490 00000000
> 3fe0: 00000000 c001d3bc 00000000 00c5387d c03ce470 00008034 00000000 00000000
> [<c0024240>] (__bug+0x18/0x24) from [<c0046a54>] (run_timer_softirq+0x308/0x36c)
> [<c0046a54>] (run_timer_softirq+0x308/0x36c) from [<c003fdf4>] (__do_softirq+0x1
> 08/0x220)
> [<c003fdf4>] (__do_softirq+0x108/0x220) from [<c003ff64>] (irq_exit+0x58/0xb0)
> [<c003ff64>] (irq_exit+0x58/0xb0) from [<c0020070>] (asm_do_IRQ+0x70/0x8c)
> [<c0020070>] (asm_do_IRQ+0x70/0x8c) from [<c02a6170>] (__irq_svc+0x50/0xd4)
> Exception stack(0xc03a3f80 to 0xc03a3fc8)
> 3f80: c0021a70 00000000 00000000 c03a2000 c03a2000 c001d3bc c001d3b8 c03a6a18
> 3fa0: 0001bfa8 410fb767 0001bf40 00000000 c03a73e8 c03a3fc8 c0021a70 c0021a74
> 3fc0: 60000013 ffffffff
> [<c02a6170>] (__irq_svc+0x50/0xd4) from [<c0021a74>] (default_idle+0x28/0x2c)
> [<c0021a74>] (default_idle+0x28/0x2c) from [<c0021f40>] (cpu_idle+0x50/0xa4)
> [<c0021f40>] (cpu_idle+0x50/0xa4) from [<c0008920>] (start_kernel+0x248/0x29c)
> [<c0008920>] (start_kernel+0x248/0x29c) from [<00008034>] (0x8034)
> Code: e1a01000 e59f000c eb09f9bf e3a03000 (e5833000)
> 
> The function the timer called was ip_expire():
> 
> [jamiei@wear linux-2.6]$ arm-none-linux-gnueabi-addr2line -e vmlinux c0237b8c
> /home/jamiei/linux-2.6/net/ipv4/ip_fragment.c:190
> 
> Reverting the commit (e9017b55189355e9e6569990a18919e83f35bccb) makes this
> crash go away. The kernel is built with preempt debugging but I don't get any
> other warnings.

This patch should fix it.

ipv4: ip_fragment: fix unbalanced rcu_read_unlock()

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------090606070808010404090303
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9f41bd3..b59430b 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -234,10 +234,9 @@ static void ip_expire(unsigned long arg)
 
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
-	}
-
 out_rcu_unlock:
-	rcu_read_unlock();
+		rcu_read_unlock();
+	}
 out:
 	spin_unlock(&qp->q.lock);
 	ipq_put(qp);

--------------090606070808010404090303--
