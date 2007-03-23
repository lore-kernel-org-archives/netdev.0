From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] forcedeth: fix nic poll
Date: Fri, 23 Mar 2007 05:49:37 -0500
Message-ID: <4603B0C1.3050100@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040704040201040605050403"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:1805 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992589AbXCWWDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 18:03:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040704040201040605050403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The nic poll routine was missing the call to the optimized irq routine. 
This patch adds the missing call for the optimized path.

See http://bugzilla.kernel.org/show_bug.cgi?id=7950 for more information.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040704040201040605050403
Content-Type: text/plain;
 name="patch-forcedeth-fix-poll"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-fix-poll"

--- orig/drivers/net/forcedeth.c	2007-03-11 20:38:20.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-03-11 20:38:24.000000000 -0500
@@ -3536,7 +3536,10 @@
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

--------------040704040201040605050403--
