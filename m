From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/4][SCTP]: Use proc_create to setup de->proc_fops.
Date: Fri, 29 Feb 2008 16:42:45 +0300
Message-ID: <47C80BD5.7090700@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Wang Chen <wangchen@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:34207 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758737AbYB2NnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 08:43:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to commit 160f17 use proc_create in two more places.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 9e214da..973f1db 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -256,12 +256,10 @@ int __init sctp_eps_proc_init(void)
 {
 	struct proc_dir_entry *p;
 
-	p = create_proc_entry("eps", S_IRUGO, proc_net_sctp);
+	p = proc_create("eps", S_IRUGO, proc_net_sctp, &sctp_eps_seq_fops);
 	if (!p)
 		return -ENOMEM;
 
-	p->proc_fops = &sctp_eps_seq_fops;
-
 	return 0;
 }
 
@@ -367,12 +365,11 @@ int __init sctp_assocs_proc_init(void)
 {
 	struct proc_dir_entry *p;
 
-	p = create_proc_entry("assocs", S_IRUGO, proc_net_sctp);
+	p = proc_create("assocs", S_IRUGO, proc_net_sctp,
+			&sctp_assocs_seq_fops);
 	if (!p)
 		return -ENOMEM;
 
-	p->proc_fops = &sctp_assocs_seq_fops;
-
 	return 0;
 }
 

