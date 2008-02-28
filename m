From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 10/15] [SCTP]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:57:37 +0800
Message-ID: <47C693A1.9030200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64448 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754397AbYB1LAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 06:00:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/sctp/objcnt.c |    5 ++---
 net/sctp/proc.c   |    4 +---
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index 14e294e..cfeb07e 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -132,12 +132,11 @@ void sctp_dbg_objcnt_init(void)
 {
 	struct proc_dir_entry *ent;
 
-	ent = create_proc_entry("sctp_dbg_objcnt", 0, proc_net_sctp);
+	ent = proc_create("sctp_dbg_objcnt", 0,
+			  proc_net_sctp, &sctp_objcnt_ops);
 	if (!ent)
 		printk(KERN_WARNING
 			"sctp_dbg_objcnt: Unable to create /proc entry.\n");
-	else
-		ent->proc_fops = &sctp_objcnt_ops;
 }
 
 /* Cleanup the objcount entry in the proc filesystem.  */
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 69bb5a6..9e214da 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -108,12 +108,10 @@ int __init sctp_snmp_proc_init(void)
 {
 	struct proc_dir_entry *p;
 
-	p = create_proc_entry("snmp", S_IRUGO, proc_net_sctp);
+	p = proc_create("snmp", S_IRUGO, proc_net_sctp, &sctp_snmp_seq_fops);
 	if (!p)
 		return -ENOMEM;
 
-	p->proc_fops = &sctp_snmp_seq_fops;
-
 	return 0;
 }
 
-- 
WCN


