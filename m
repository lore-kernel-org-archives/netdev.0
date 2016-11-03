From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/13] debugfs: constify argument to debugfs_real_fops()
Date: Thu,  3 Nov 2016 13:58:55 +0000
Message-ID: <1478181538-20778-11-git-send-email-jakub.kicinski@netronome.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Nicolai Stange <nicstange@gmail.com>,
        Christian Lamparter <chunkeey@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35247 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757810AbcKCN7Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:59:25 -0400
Received: by mail-wm0-f41.google.com with SMTP id a197so207212052wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:59:24 -0700 (PDT)
In-Reply-To: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

seq_file users can only access const version of file pointer,
make parameter to debugfs_real_fops() const.

CC: Nicolai Stange <nicstange@gmail.com>
CC: Christian Lamparter <chunkeey@gmail.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/debugfs.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
index 4d3f0d1aec73..bf1907d96097 100644
--- a/include/linux/debugfs.h
+++ b/include/linux/debugfs.h
@@ -52,7 +52,8 @@ struct debugfs_regset32 {
  * Must only be called under the protection established by
  * debugfs_use_file_start().
  */
-static inline const struct file_operations *debugfs_real_fops(struct file *filp)
+static inline const struct file_operations *
+debugfs_real_fops(const struct file *filp)
 	__must_hold(&debugfs_srcu)
 {
 	/*
-- 
1.9.1
