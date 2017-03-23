From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] kcm: return immediately after copy_from_user() failure
Date: Thu, 23 Mar 2017 11:03:31 -0700
Message-ID: <1490292211-19767-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35143 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752321AbdCWSDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 14:03:41 -0400
Received: by mail-pg0-f68.google.com with SMTP id g2so37542614pge.2
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 11:03:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason to continue after a copy_from_user()
failure.

Fixes: ab7ac4eb9832 ("kcm: Kernel Connection Multiplexor module")
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/kcm/kcmsock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 309062f..31762f7 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1687,7 +1687,7 @@ static int kcm_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		struct kcm_attach info;
 
 		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
-			err = -EFAULT;
+			return -EFAULT;
 
 		err = kcm_attach_ioctl(sock, &info);
 
@@ -1697,7 +1697,7 @@ static int kcm_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		struct kcm_unattach info;
 
 		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
-			err = -EFAULT;
+			return -EFAULT;
 
 		err = kcm_unattach_ioctl(sock, &info);
 
@@ -1708,7 +1708,7 @@ static int kcm_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		struct socket *newsock = NULL;
 
 		if (copy_from_user(&info, (void __user *)arg, sizeof(info)))
-			err = -EFAULT;
+			return -EFAULT;
 
 		err = kcm_clone(sock, &info, &newsock);
 
-- 
2.5.5
