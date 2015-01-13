From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 1/3] xen: add page_to_mfn()
Date: Tue, 13 Jan 2015 17:16:42 +0000
Message-ID: <1421169404-27461-2-git-send-email-david.vrabel@citrix.com>
References: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59758 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbbAMRUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:20:23 -0500
In-Reply-To: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pfn_to_mfn(page_to_pfn(p)) is a common use case so add a generic
helper for it.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 include/xen/page.h |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/xen/page.h b/include/xen/page.h
index 12765b6..c5ed20b 100644
--- a/include/xen/page.h
+++ b/include/xen/page.h
@@ -3,6 +3,11 @@
 
 #include <asm/xen/page.h>
 
+static inline unsigned long page_to_mfn(struct page *page)
+{
+	return pfn_to_mfn(page_to_pfn(page));
+}
+
 struct xen_memory_region {
 	phys_addr_t start;
 	phys_addr_t size;
-- 
1.7.10.4
