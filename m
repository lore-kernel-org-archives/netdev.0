From: Tushar Behera <tushar.behera@linaro.org>
Subject: [PATCH 08/14] xen: netback: Remove redundant check on unsigned variable
Date: Fri, 16 Nov 2012 12:20:40 +0530
Message-ID: <1353048646-10935-9-git-send-email-tushar.behera@linaro.org>
References: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
Cc: patches@linaro.org, Ian Campbell <ian.campbell@citrix.com>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to check whether unsigned variable is less than 0.

CC: Ian Campbell <ian.campbell@citrix.com>
CC: xen-devel@lists.xensource.com
CC: netdev@vger.kernel.org
Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
---
 drivers/net/xen-netback/netback.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index aab8677..515e10c 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -190,14 +190,14 @@ static int get_page_ext(struct page *pg,
 
 	group = ext.e.group - 1;
 
-	if (group < 0 || group >= xen_netbk_group_nr)
+	if (group >= xen_netbk_group_nr)
 		return 0;
 
 	netbk = &xen_netbk[group];
 
 	idx = ext.e.idx;
 
-	if ((idx < 0) || (idx >= MAX_PENDING_REQS))
+	if (idx >= MAX_PENDING_REQS)
 		return 0;
 
 	if (netbk->mmap_pages[idx] != pg)
-- 
1.7.4.1
