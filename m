From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1091/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:15:46 +0800
Message-ID: <20160802121546.22862-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhelgaas@google.com, nikolay@cumulusnetworks.com,
	nhorman@redhat.com, aduyck@mirantis.com, chuansheng.liu@intel.com,
	baolex.ni@intel.com, aarcange@redhat.com, aryabinin@virtuozzo.com
To: davem@davemloft.net, gustavo@padovan.org, johan.hedberg@gmail.com,
	jiangshanlai@gmail.com, m.chehab@samsung.com,
	gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:8454 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965654AbcHBMx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/core/netpoll.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 94acfc8..fac805d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -60,7 +60,7 @@ static void zap_completion_queue(void);
 static void netpoll_async_cleanup(struct work_struct *work);
 
 static unsigned int carrier_timeout = 4;
-module_param(carrier_timeout, uint, 0644);
+module_param(carrier_timeout, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 #define np_info(np, fmt, ...)				\
 	pr_info("%s: " fmt, np->name, ##__VA_ARGS__)
-- 
2.9.2
