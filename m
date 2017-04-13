From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] kcm: remove a useless copy_from_user()
Date: Thu, 13 Apr 2017 11:38:02 -0700
Message-ID: <1492108682-30505-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35221 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752273AbdDMSiQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 14:38:16 -0400
Received: by mail-pf0-f194.google.com with SMTP id a188so12188701pfa.2
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 11:38:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct kcm_clone only contains fd, and kcm_clone() only
writes this struct, so there is no need to copy it from user.

Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/kcm/kcmsock.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 31762f7..deca20f 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1707,11 +1707,7 @@ static int kcm_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		struct kcm_clone info;
 		struct socket *newsock = NULL;
 
-		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
-			return -EFAULT;
-
 		err = kcm_clone(sock, &info, &newsock);
-
 		if (!err) {
 			if (copy_to_user((void __user *)arg, &info,
 					 sizeof(info))) {
-- 
2.5.5
