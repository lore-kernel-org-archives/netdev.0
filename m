From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [XFRM] AUDIT: Fix audit buffer leakage in error path.
Date: Tue, 13 Feb 2007 00:34:29 +0900 (JST)
Message-ID: <20070213.003429.73173216.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54468 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932969AbXBLPe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 10:34:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b7e537f..af85ac9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1999,7 +1999,7 @@ void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
 
 	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
 	if (audit_buf == NULL)
-	return;
+		return;
 
 	switch(type) {
 	case AUDIT_MAC_IPSEC_ADDSA:
@@ -2015,7 +2015,7 @@ void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
 		audit_log_format(audit_buf, "SPD delete: auid=%u", auid);
 		break;
 	default:
-		return;
+		goto out;
 	}
 
 	if (sid != 0 &&
@@ -2085,6 +2085,7 @@ void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
 				"ESP" : "IPCOMP"));
 
 	audit_log_format(audit_buf, " res=%u", result);
+out:
 	audit_log_end(audit_buf);
 }
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
