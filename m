From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 5/9] net/dccp: dccp_list_has_service can be boolean
Date: Thu,  8 Oct 2015 21:28:58 +0800
Message-ID: <1444310942-4428-6-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes dccp_list_has_service return bool due to this
particular function only using either one or zero as its return
value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/dccp.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 2210254..61d042b 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -202,16 +202,16 @@ struct dccp_service_list {
 #define DCCP_SERVICE_INVALID_VALUE htonl((__u32)-1)
 #define DCCP_SERVICE_CODE_IS_ABSENT		0
 
-static inline int dccp_list_has_service(const struct dccp_service_list *sl,
+static inline bool dccp_list_has_service(const struct dccp_service_list *sl,
 					const __be32 service)
 {
 	if (likely(sl != NULL)) {
 		u32 i = sl->dccpsl_nr;
 		while (i--)
 			if (sl->dccpsl_list[i] == service)
-				return 1;
+				return true;
 	}
-	return 0;
+	return false;
 }
 
 struct dccp_ackvec;
-- 
1.9.1
