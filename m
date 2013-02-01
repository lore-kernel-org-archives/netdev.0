From: roy.qing.li@gmail.com
Subject: [PATCH 2/2 net-next] xfrm: fix a unbalanced lock
Date: Fri,  1 Feb 2013 13:17:16 +0800
Message-ID: <1359695836-5666-2-git-send-email-roy.qing.li@gmail.com>
References: <1359695836-5666-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:62829 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab3BAFRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 00:17:42 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so2090538pab.19
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 21:17:42 -0800 (PST)
In-Reply-To: <1359695836-5666-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 2c5aa8d..e894ac6 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -64,7 +64,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEINVALID);
-			goto error_nolock;
+			goto error;
 		}
 
 		err = xfrm_state_check_expire(x);
-- 
1.7.10.4
