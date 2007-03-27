From: akpm@linux-foundation.org
Subject: [patch 10/10] forcedeth: work around NULL skb dereference crash
Date: Mon, 26 Mar 2007 21:47:29 -0800
Message-ID: <200703270547.l2R5lTZg008278@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, mingo@elte.hu,
	aabdulla@nvidia.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40161 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934009AbXC0Fsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:48:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>

work around a NULL skb dereference crash that occurs during high load.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff -puN drivers/net/forcedeth.c~forcedeth-work-around-null-skb-dereference-crash drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-work-around-null-skb-dereference-crash
+++ a/drivers/net/forcedeth.c
@@ -1902,6 +1902,16 @@ static void nv_tx_done(struct net_device
 						np->stats.tx_carrier_errors++;
 					np->stats.tx_errors++;
 				} else {
+					if (!np->get_tx_ctx->skb) {
+						printk("get_tx: %td, put_tx: "
+							"%td\n",
+							np->get_tx_ctx -
+							    np->first_tx_ctx,
+							np->put_tx_ctx -
+							    np->first_tx_ctx);
+						WARN_ON(1);
+						break;
+					}
 					np->stats.tx_packets++;
 					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
@@ -1917,6 +1927,16 @@ static void nv_tx_done(struct net_device
 						np->stats.tx_carrier_errors++;
 					np->stats.tx_errors++;
 				} else {
+					if (!np->get_tx_ctx->skb) {
+						printk("get_tx: %td, put_tx: "
+							"%td\n",
+							np->get_tx_ctx -
+							    np->first_tx_ctx,
+							np->put_tx_ctx -
+							    np->first_tx_ctx);
+						WARN_ON(1);
+						break;
+					}
 					np->stats.tx_packets++;
 					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
_
