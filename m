From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/3] NET: Use proc_net_fops_create() and proc_net_remove()
 in net/core
Date: Mon, 08 Sep 2003 03:41:02 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908.034102.33137738.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[1/3] Use proc_net_fops_create() and proc_net_remove() in net/core.

Index: linux-2.6/net/core/dev.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/core/dev.c,v
retrieving revision 1.85
diff -u -r1.85 dev.c
--- linux-2.6/net/core/dev.c	2 Sep 2003 01:25:27 -0000	1.85
+++ linux-2.6/net/core/dev.c	7 Sep 2003 17:02:52 -0000
@@ -1994,26 +1994,21 @@
 
 static int __init dev_proc_init(void)
 {
-	struct proc_dir_entry *p;
 	int rc = -ENOMEM;
 
-	p = create_proc_entry("dev", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("dev", S_IRUGO, &dev_seq_fops))
 		goto out;
-	p->proc_fops = &dev_seq_fops;
-	p = create_proc_entry("softnet_stat", S_IRUGO, proc_net);
-	if (!p)
+	if (!proc_net_fops_create("softnet_stat", S_IRUGO, &softnet_seq_fops))
 		goto out_dev;
-	p->proc_fops = &softnet_seq_fops;
 	if (wireless_proc_init())
 		goto out_softnet;
 	rc = 0;
 out:
 	return rc;
 out_softnet:
-	remove_proc_entry("softnet_stat", proc_net);
+	proc_net_remove("softnet_stat");
 out_dev:
-	remove_proc_entry("dev", proc_net);
+	proc_net_remove("dev");
 	goto out;
 }
 #else

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
