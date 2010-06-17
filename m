From: Eran Liberty <liberty@extricom.com>
Subject: [PATCH] gainfar.c : skb_over_panic
Date: Thu, 17 Jun 2010 19:32:54 +0300
Message-ID: <4C1A4E36.5060902@extricom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000009090106040501010003"
To: galak@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.extricom.com ([212.235.17.194]:36545 "HELO
	smtp.extricom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with SMTP id S933068Ab0FQQzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 12:55:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000009090106040501010003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Kumar,

I have demonstrated skb_over_panic with linux 2.6.32.15 on a mpc8548 
based product.

--------------- skb_over_panic snip ---------------
[  949.759344] skb_over_panic: text:c020fcec len:1474 put:1474 head:d8dc4000
data:d8dc4140 tail:0xd8dc4822 end:0xd8dc4760 dev:eth0
[  949.770913] ------------[ cut here ]------------
[  949.775522] kernel BUG at net/core/skbuff.c:127!
[  949.780132] Oops: Exception in kernel mode, sig: 5 [#1]
[  949.785347] EXTRICOM85xx
[  949.787870] Modules linked in: ...
[  949.806518] NIP: c02325bc LR: c02325bc CTR: c01f01f4
[  949.811475] REGS: d9a59bb0 TRAP: 0700   Tainted: P            (2.6.32.15)
[  949.818253] MSR: 00029000 <EE,ME,CE>  CR: 24004422  XER: 20000000
[  949.824364] TASK = d9a2a580[1877] 'insmod' THREAD: d9a58000
[  949.829753] GPR00: c02325bc d9a59c60 d9a2a580 00000089 0000f1d1 ffffffff
c01ed50c 0000f1d1
[  949.838132] GPR08: 00000030 c04accb4 0000f1d1 00004000 84004422 10019100
100936f8 dc3152f0
[  949.846510] GPR16: 00000040 00029000 c041fa14 dc315340 00000001 c041fa00
0000000a d9a65800
[  949.854887] GPR24: d9a58000 0000003f d9e42480 dc315000 d9a65950 000005c2
d9d05900 d8dc4260
[  949.863461] NIP [c02325bc] skb_over_panic+0x48/0x5c
[  949.868331] LR [c02325bc] skb_over_panic+0x48/0x5c
[  949.873111] Call Trace:
[  949.875551] [d9a59c60] [c02325bc] skb_over_panic+0x48/0x5c (unreliable)
[  949.882166] [d9a59c70] [c0233cf8] skb_put+0x5c/0x60
[  949.887051] [d9a59c80] [c020fcec] gfar_clean_rx_ring+0x210/0x444
[  949.893054] [d9a59cd0] [c0211620] gfar_poll+0x238/0x364
[  949.898284] [d9a59d20] [c02403e4] net_rx_action+0x8c/0x178
[  949.903773] [d9a59d50] [c004278c] __do_softirq+0xa0/0x110
[  949.909171] [d9a59d90] [c0004c24] do_softirq+0x54/0x58
[  949.914306] [d9a59da0] [c0042604] irq_exit+0x98/0x9c
[  949.919267] [d9a59db0] [c0004edc] do_IRQ+0x9c/0xb4
[  949.924060] [d9a59dd0] [c000fe8c] ret_from_except+0x0/0x18
[  949.929544] [d9a59e90] [c00685d0] load_module+0x64/0x1638
[  949.934938] [d9a59f20] [c0069c28] sys_init_module+0x84/0x218
[  949.940593] [d9a59f40] [c000f838] ret_from_syscall+0x0/0x3c
[  949.946159] Instruction dump:
[  949.949121] 80a30054 2f800000 80e300a0 810300a4 81630098 8143009c 
419e0020
3c60c042
[  949.956889] 90010008 7d695b78 38633b2c 4be0b2fd <0fe00000> 48000000 
3d20c03f
38090970
[  949.964835] Kernel panic - not syncing: Fatal exception in interrupt
[  949.971179] Call Trace:
[  949.973619] [d9a59a00] [c0006ff0] show_stack+0x44/0x16c (unreliable)
[  949.979972] [d9a59a40] [c003c8b4] panic+0x90/0x168
[  949.984759] [d9a59a90] [c000ceb8] die+0x164/0x19c
[  949.989459] [d9a59ab0] [c000d174] _exception+0x120/0x144
[  949.994768] [d9a59ba0] [c000fe40] ret_from_except_full+0x0/0x4c
[  950.000685] [d9a59c60] [c02325bc] skb_over_panic+0x48/0x5c
[  950.006166] [d9a59c70] [c0233cf8] skb_put+0x5c/0x60
[  950.011042] [d9a59c80] [c020fcec] gfar_clean_rx_ring+0x210/0x444
[  950.017045] [d9a59cd0] [c0211620] gfar_poll+0x238/0x364
[  950.022267] [d9a59d20] [c02403e4] net_rx_action+0x8c/0x178
[  950.027750] [d9a59d50] [c004278c] __do_softirq+0xa0/0x110
[  950.033145] [d9a59d90] [c0004c24] do_softirq+0x54/0x58
[  950.038279] [d9a59da0] [c0042604] irq_exit+0x98/0x9c
[  950.043239] [d9a59db0] [c0004edc] do_IRQ+0x9c/0xb4
[  950.048027] [d9a59dd0] [c000fe8c] ret_from_except+0x0/0x18
[  950.053508] [d9a59e90] [c00685d0] load_module+0x64/0x1638
[  950.058902] [d9a59f20] [c0069c28] sys_init_module+0x84/0x218
[  950.064558] [d9a59f40] [c000f838] ret_from_syscall+0x0/0x3c
[  950.070126] Rebooting in 1 seconds..
[  951.067504] ------------[ cut here ]------------


The skb_over_panic occurs due to calling skb_put() within 
gfar_clean_rx_ring(). This happens if (and only if) shortly prior to the 
event and a few lined above the skb_put(), an skb was queued back to the 
priv->rx_recycle queue due to RXBD_LAST or RXBD_ERR status.

--------------- driver/net/gianfar.c: gfar_clean_rx_ring() ---------------
1851                 if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
1852                                  bdp->status & RXBD_ERR)) {
1853                         count_errors(bdp->status, dev);
1854
1855                         if (unlikely(!newskb))
1856                                 newskb = skb;
1857                         else if (skb) {
1858                                 /*
1859                                  * We need to reset ->data to what it
1860                                  * was before gfar_new_skb() re-aligned
1861                                  * it to an RXBUF_ALIGNMENT boundary
1862                                  * before we put the skb back on the
1863                                  * recycle list.
1864                                  */
1865                                 skb->data = skb->head + NET_SKB_PAD;

This happens first...

1866                                 __skb_queue_head(&priv->rx_recycle, 
skb);
1867                         }
1868                 } else {
1869                         /* Increment the number of packets */
1870                         dev->stats.rx_packets++;
1871                         howmany++;
1872
1873                         if (likely(skb)) {
1874                                 pkt_len = bdp->length - ETH_FCS_LEN;
1875                                 /* Remove the FCS from the packet 
length */

After relatively short time this will create skb_over_panic

1876                                 skb_put(skb, pkt_len);
1877                                 dev->stats.rx_bytes += pkt_len;
1878
1879                                 if (in_irq() || irqs_disabled())

--------------------------------------------------------------------------

As seen in line 1865 there is an attempt to fix the skb prior to its 
re-queuing but we can look at gfar_clean_tx_ring() where it calls 
skb_recycle_check() prior to re-queuing, which looks more professional.

--------------- driver/net/gianfar.c: gfar_clean_tx_ring() ---------------
1621                 if (skb_queue_len(&priv->rx_recycle) < 
priv->rx_ring_size &&
1622                                 skb_recycle_check(skb, 
priv->rx_buffer_size +
1623                                         RXBUF_ALIGNMENT))
1624                         __skb_queue_head(&priv->rx_recycle, skb);
1625                 else
1626                         dev_kfree_skb_any(skb);
--------------------------------------------------------------------------

Duplicating the above code for the gfar_clean_rx_ring() function 
effectively eliminated the  skb_over_run and thus I propose the attached 
patch

-- Liberty
<https://svn.extricom.com/lxr/ident?v=linux-2.6.32.15;i=gfar_clean_rx_ring>

--------------000009090106040501010003
Content-Type: text/x-diff;
 name="gianfar_skb_over_panic.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gianfar_skb_over_panic.patch"

---
 drivers/net/gianfar.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1854,15 +1854,13 @@
 			if (unlikely(!newskb))
 				newskb = skb;
 			else if (skb) {
-				/*
-				 * We need to reset ->data to what it
-				 * was before gfar_new_skb() re-aligned
-				 * it to an RXBUF_ALIGNMENT boundary
-				 * before we put the skb back on the
-				 * recycle list.
-				 */
-				skb->data = skb->head + NET_SKB_PAD;
-				__skb_queue_head(&priv->rx_recycle, skb);
+				if (skb_queue_len(&priv->rx_recycle) < priv->rx_ring_size &&
+						skb_recycle_check(skb, priv->rx_buffer_size +
+							RXBUF_ALIGNMENT)) {
+					__skb_queue_head(&priv->rx_recycle, skb);
+				} else {
+					dev_kfree_skb_any(skb);
+				}
 			}
 		} else {
 			/* Increment the number of packets */

--------------000009090106040501010003--
