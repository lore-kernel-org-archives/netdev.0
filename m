From: akpm@linux-foundation.org
Subject: [patch 08/10] forcedeth: fix nic poll
Date: Mon, 26 Mar 2007 21:47:27 -0800
Message-ID: <200703270547.l2R5lRJw008272@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	aabdulla@nvidia.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40122 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934007AbXC0Frc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:47:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ayaz Abdulla <aabdulla@nvidia.com>

The nic poll routine was missing the call to the optimized irq routine. 
This patch adds the missing call for the optimized path.

See http://bugzilla.kernel.org/show_bug.cgi?id=7950 for more information.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -puN drivers/net/forcedeth.c~forcedeth-fix-nic-poll drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-fix-nic-poll
+++ a/drivers/net/forcedeth.c
@@ -3536,7 +3536,10 @@ static void nv_do_nic_poll(unsigned long
 	pci_push(base);
 
 	if (!using_multi_irqs(dev)) {
-		nv_nic_irq(0, dev);
+		if (np->desc_ver == DESC_VER_3)
+			nv_nic_irq_optimized(0, dev);
+		else
+			nv_nic_irq(0, dev);
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
_
