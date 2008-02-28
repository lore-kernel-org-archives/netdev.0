From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 01/15] [APPLETALK]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 18:54:51 +0800
Message-ID: <47C692FB.9010201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53834 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751662AbYB1K5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:57:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Davem mentioned in his recently patch
(d9595a7b9c777d45a74774f1428c263a0a47f4c0)
that the procfs visibility should occur after
the ->proc_fops are setup.

And also, Alexey provide proc_create() to make
sure that ->proc_fops is setup before gluing PDE
to main tree.

We use proc_create().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/appletalk/atalk_proc.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
index 8e8dcfd..162199a 100644
--- a/net/appletalk/atalk_proc.c
+++ b/net/appletalk/atalk_proc.c
@@ -283,25 +283,24 @@ int __init atalk_proc_init(void)
 		goto out;
 	atalk_proc_dir->owner = THIS_MODULE;
 
-	p = create_proc_entry("interface", S_IRUGO, atalk_proc_dir);
+	p = proc_create("interface", S_IRUGO, atalk_proc_dir,
+			&atalk_seq_interface_fops);
 	if (!p)
 		goto out_interface;
-	p->proc_fops = &atalk_seq_interface_fops;
 
-	p = create_proc_entry("route", S_IRUGO, atalk_proc_dir);
+	p = proc_create("route", S_IRUGO, atalk_proc_dir,
+			&atalk_seq_route_fops);
 	if (!p)
 		goto out_route;
-	p->proc_fops = &atalk_seq_route_fops;
 
-	p = create_proc_entry("socket", S_IRUGO, atalk_proc_dir);
+	p = proc_create("socket", S_IRUGO, atalk_proc_dir,
+			&atalk_seq_socket_fops);
 	if (!p)
 		goto out_socket;
-	p->proc_fops = &atalk_seq_socket_fops;
 
-	p = create_proc_entry("arp", S_IRUGO, atalk_proc_dir);
+	p = proc_create("arp", S_IRUGO, atalk_proc_dir, &atalk_seq_arp_fops);
 	if (!p)
 		goto out_arp;
-	p->proc_fops = &atalk_seq_arp_fops;
 
 	rc = 0;
 out:
-- 
WCN



