From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 1/8] netback: don't bind kthread to cpu
Date: Fri, 15 Feb 2013 16:00:02 +0000
Message-ID: <1360944010-15336-2-git-send-email-wei.liu2@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27169 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756350Ab3BOQAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 11:00:54 -0500
In-Reply-To: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The initialization process makes an assumption that the online cpus are
numbered from 0 to xen_netbk_group_nr-1,  which is not always true.

As we only need a pool of worker threads, simply don't bind them to specific
cpus.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 3ae49b1..db8d45a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1729,8 +1729,6 @@ static int __init netback_init(void)
 			goto failed_init;
 		}
 
-		kthread_bind(netbk->task, group);
-
 		INIT_LIST_HEAD(&netbk->net_schedule_list);
 
 		spin_lock_init(&netbk->net_schedule_list_lock);
-- 
1.7.10.4
