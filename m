From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [patch -v3 10/22] airo: use simple_read_from_buffer
Date: Wed, 04 Jun 2008 20:56:43 +0900
Message-ID: <20080604115751.496499508@gmail.com>
References: <20080604115633.116832712@gmail.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:20551 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760755AbYFDMKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 08:10:13 -0400
Received: by wa-out-1112.google.com with SMTP id j37so41414waf.23
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2008 05:10:13 -0700 (PDT)
Content-Disposition: inline; filename=airo-use-simple-read-from-buffer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
---
 drivers/net/wireless/airo.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

Index: 2.6-git/drivers/net/wireless/airo.c
===================================================================
--- 2.6-git.orig/drivers/net/wireless/airo.c
+++ 2.6-git/drivers/net/wireless/airo.c
@@ -4560,22 +4560,13 @@ static ssize_t proc_read( struct file *f
 			  size_t len,
 			  loff_t *offset )
 {
-	loff_t pos = *offset;
-	struct proc_data *priv = (struct proc_data*)file->private_data;
+	struct proc_data *priv = file->private_data;
 
 	if (!priv->rbuffer)
 		return -EINVAL;
 
-	if (pos < 0)
-		return -EINVAL;
-	if (pos >= priv->readlen)
-		return 0;
-	if (len > priv->readlen - pos)
-		len = priv->readlen - pos;
-	if (copy_to_user(buffer, priv->rbuffer + pos, len))
-		return -EFAULT;
-	*offset = pos + len;
-	return len;
+	return simple_read_from_buffer(buffer, len, offset, priv->rbuffer,
+					priv->readlen);
 }
 
 /*

-- 
