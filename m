From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/4] clip: get rid of PROC_FS ifdef
Date: Thu, 13 Apr 2006 15:23:15 -0700
Message-ID: <20060413152315.05051c08@localhost.localdomain>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<20060413151945.0f181d04@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14224 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932467AbWDMWZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 18:25:56 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060413151945.0f181d04@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't need the ifdef here since create_proc_entry() is stubbed to always
return NULL.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- clip.orig/net/atm/clip.c	2006-04-13 15:18:21.000000000 -0700
+++ clip/net/atm/clip.c	2006-04-13 15:20:26.000000000 -0700
@@ -976,6 +976,7 @@
 
 static int __init atm_clip_init(void)
 {
+	struct proc_dir_entry *p;
 	neigh_table_init(&clip_tbl);
 
 	clip_tbl_hook = &clip_tbl;
@@ -985,15 +986,9 @@
 
 	setup_timer(&idle_timer, idle_timer_check, 0);
 
-#ifdef CONFIG_PROC_FS
-	{
-		struct proc_dir_entry *p;
-
-		p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
-		if (p)
-			p->proc_fops = &arp_seq_fops;
-	}
-#endif
+	p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
+	if (p)
+		p->proc_fops = &arp_seq_fops;
 
 	return 0;
 }
