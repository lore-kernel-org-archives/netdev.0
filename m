From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETFILTER]: Net namespace leak when reading /proc/net/xxx_tables_names.
Date: Mon, 21 Apr 2008 18:52:05 +0400
Message-ID: <480CAA15.6060003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Alexey Dobriyan <adobriyan@openvz.org>
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58062 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbYDUOx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 10:53:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The seq_open_net() call should be accompanied with seq_release_net() one.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index f52f7f8..11b22ab 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -787,7 +787,7 @@ static const struct file_operations xt_table_ops = {
 	.open	 = xt_table_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 static void *xt_match_seq_start(struct seq_file *seq, loff_t *pos)
