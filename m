From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] BUG_ON() bad input to request_irq
Date: Thu, 17 Jan 2008 17:59:58 +1100
Message-ID: <200801171759.59029.rusty@rustcorp.com.au>
References: <200801171757.59026.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36578 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570AbYAQHAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 02:00:39 -0500
In-Reply-To: <200801171757.59026.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there any reason why these bugs should be treated gently?  The
caller might not want to check NR_IRQS and IRQ_NOREQUEST cases, but
a NULL handler or NULL dev_id w/ shared are coding bugs.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 kernel/irq/manage.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff -r c2eb8ef5a0be kernel/irq/manage.c
--- a/kernel/irq/manage.c	Thu Jan 17 15:48:03 2008 +1100
+++ b/kernel/irq/manage.c	Thu Jan 17 15:49:33 2008 +1100
@@ -532,13 +532,12 @@ int request_irq(unsigned int irq, irq_ha
 	 * which interrupt is which (messes up the interrupt freeing
 	 * logic etc).
 	 */
-	if ((irqflags & IRQF_SHARED) && !dev_id)
-		return -EINVAL;
+	BUG_ON((irqflags & IRQF_SHARED) && !dev_id);
+	BUG_ON(!handler);
+
 	if (irq >= NR_IRQS)
 		return -EINVAL;
 	if (irq_desc[irq].status & IRQ_NOREQUEST)
-		return -EINVAL;
-	if (!handler)
 		return -EINVAL;
 
 	action = kmalloc(sizeof(struct irqaction), GFP_ATOMIC);
