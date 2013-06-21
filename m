From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] xen-netback: double free on unload
Date: Fri, 21 Jun 2013 09:20:08 +0300
Message-ID: <20130621062008.GA10873@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22470 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030248Ab3FUGUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 02:20:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a typo here, "i" vs "j", so we would crash on module_exit().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index a0b50ad..130bcb2 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1968,8 +1968,8 @@ static void __exit netback_fini(void)
 		del_timer_sync(&netbk->net_timer);
 		kthread_stop(netbk->task);
 		for (j = 0; j < MAX_PENDING_REQS; j++) {
-			if (netbk->mmap_pages[i])
-				__free_page(netbk->mmap_pages[i]);
+			if (netbk->mmap_pages[j])
+				__free_page(netbk->mmap_pages[j]);
 		}
 	}
 
