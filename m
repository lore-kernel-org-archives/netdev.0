From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Tue, 28 Apr 2009 19:07:39 +0000
Message-ID: <1240945659.8819.9.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f128.google.com ([209.85.221.128]:33514 "EHLO
	mail-qy0-f128.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbZD1Tck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 15:32:40 -0400
Received: by qyk34 with SMTP id 34so336714qyk.33
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2009 12:32:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two memory barriers in performance-critical paths are not needed
on x86.  Even if some other architecture does buffer PCI I/O space
writes, the existing memory-mapped I/O barriers are unlikely to be what
is needed.

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 drivers/net/pcnet32.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index e5e8c59..1c35e1d 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1405,7 +1405,7 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 
 		/* Set interrupt enable. */
 		lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
-		mmiowb();
+
 		spin_unlock_irqrestore(&lp->lock, flags);
 	}
 	return work_done;
@@ -2597,7 +2597,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 			val = lp->a.read_csr(ioaddr, CSR3);
 			val |= 0x5f00;
 			lp->a.write_csr(ioaddr, CSR3, val);
-			mmiowb();
+
 			__napi_schedule(&lp->napi);
 			break;
 		}
-- 
1.5.4.3



