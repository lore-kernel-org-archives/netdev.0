From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] NET: use proc_net_fops_create() for /proc/net/wireless
Date: Sat, 13 Sep 2003 14:29:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913.142929.91737848.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

use proc_net_fops_create() for /proc/net/wireless

===== net/core/wireless.c 1.13 vs edited =====
--- 1.13/net/core/wireless.c	Tue Sep  9 10:35:35 2003
+++ edited/net/core/wireless.c	Sat Sep 13 14:09:03 2003
@@ -495,15 +495,10 @@
 
 int __init wireless_proc_init(void)
 {
-	struct proc_dir_entry *p;
-	int rc = 0;
+	if (!proc_net_fops_create("wireless", S_IRUGO, &wireless_seq_fops))
+		return -ENOMEM;
 
-	p = create_proc_entry("wireless", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &wireless_seq_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	return 0;
 }
 #endif	/* CONFIG_PROC_FS */
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
