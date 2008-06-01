From: akinobu.mita@gmail.com
Subject: [patch -v2 01/23] sunrpc: use simple_read_from_buffer
Date: Mon, 02 Jun 2008 08:13:30 +0900
Message-ID: <20080601231451.529328123@gmail.com>
References: <20080601231329.223608711@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:24561 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbYFAX1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 19:27:06 -0400
Received: by rv-out-0506.google.com with SMTP id l9so767550rvb.1
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2008 16:27:06 -0700 (PDT)
Content-Disposition: inline; filename=sunrpc-simple-read-from-buffer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/sunrpc/cache.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

Index: 2.6-git/net/sunrpc/cache.c
===================================================================
--- 2.6-git.orig/net/sunrpc/cache.c
+++ 2.6-git/net/sunrpc/cache.c
@@ -1271,20 +1271,11 @@ static ssize_t read_flush(struct file *f
 {
 	struct cache_detail *cd = PDE(file->f_path.dentry->d_inode)->data;
 	char tbuf[20];
-	unsigned long p = *ppos;
 	size_t len;
 
-	sprintf(tbuf, "%lu\n", cd->flush_time);
-	len = strlen(tbuf);
-	if (p >= len)
-		return 0;
-	len -= p;
-	if (len > count)
-		len = count;
-	if (copy_to_user(buf, (void*)(tbuf+p), len))
-		return -EFAULT;
-	*ppos += len;
-	return len;
+	len = sprintf(tbuf, "%lu\n", cd->flush_time);
+
+	return simple_read_from_buffer(buf, count, ppos, tbuf, len);
 }
 
 static ssize_t write_flush(struct file * file, const char __user * buf,

-- 
