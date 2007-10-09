From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 6/6][NET-2.6.24] Make the sunrpc use the seq_open_private()
Date: Tue, 09 Oct 2007 20:04:23 +0400
Message-ID: <470BA687.8030202@openvz.org>
References: <470BA351.3070208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Neil Brown <neilb@cse.unsw.edu.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43801 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbXJIQHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 12:07:05 -0400
In-Reply-To: <470BA351.3070208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just switch to the consolidated code.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: Neil Brown <neilb@cse.unsw.edu.au>

---

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index ebe344f..8e05557 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1218,23 +1218,15 @@ static const struct seq_operations cache
 
 static int content_open(struct inode *inode, struct file *file)
 {
-	int res;
 	struct handle *han;
 	struct cache_detail *cd = PDE(inode)->data;
 
-	han = kmalloc(sizeof(*han), GFP_KERNEL);
+	han = __seq_open_private(file, &cache_content_op, sizeof(*han));
 	if (han == NULL)
 		return -ENOMEM;
 
 	han->cd = cd;
-
-	res = seq_open(file, &cache_content_op);
-	if (res)
-		kfree(han);
-	else
-		((struct seq_file *)file->private_data)->private = han;
-
-	return res;
+	return 0;
 }
 
 static const struct file_operations content_file_operations = {

