From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 6/9] net/dccp: dccp_bad_service_code can be boolean
Date: Thu,  8 Oct 2015 21:28:59 +0800
Message-ID: <1444310942-4428-7-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes dccp_bad_service_code return bool due to these
particular functions only using either one or zero as their return
value.

dccp_list_has_service is also been made return bool in this patchset.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 net/dccp/dccp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index bebc735..a250825 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -325,13 +325,13 @@ void dccp_send_close(struct sock *sk, const int active);
 int dccp_invalid_packet(struct sk_buff *skb);
 u32 dccp_sample_rtt(struct sock *sk, long delta);
 
-static inline int dccp_bad_service_code(const struct sock *sk,
+static inline bool dccp_bad_service_code(const struct sock *sk,
 					const __be32 service)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
 
 	if (dp->dccps_service == service)
-		return 0;
+		return false;
 	return !dccp_list_has_service(dp->dccps_service_list, service);
 }
 
-- 
1.9.1
