From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 1/3] xfrm: simplify the exit path of xfrm_output_one()
Date: Sat,  1 Jun 2013 20:23:15 -0600
Message-ID: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:49999 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893Ab3FBCYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 22:24:47 -0400
Received: by mail-ie0-f176.google.com with SMTP id at20so7237116iec.35
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 19:24:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up unnecessary assignment and jump. While there, fix up the label
name.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/xfrm/xfrm_output.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 0cf003d..eb4a842 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -89,7 +89,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		err = x->type->output(x, skb);
 		if (err == -EINPROGRESS)
-			goto out_exit;
+			goto out;
 
 resume:
 		if (err) {
@@ -107,15 +107,14 @@ resume:
 		x = dst->xfrm;
 	} while (x && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL));
 
-	err = 0;
+	return 0;
 
-out_exit:
-	return err;
 error:
 	spin_unlock_bh(&x->lock);
 error_nolock:
 	kfree_skb(skb);
-	goto out_exit;
+out:
+	return err;
 }
 
 int xfrm_output_resume(struct sk_buff *skb, int err)
