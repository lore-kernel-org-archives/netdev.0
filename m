From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 15/15] [X25]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:58:48 +0800
Message-ID: <47C693E8.7040003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54486 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756688AbYB1LBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 06:01:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/x25/x25_proc.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/x25/x25_proc.c b/net/x25/x25_proc.c
index 3f52b09..1afa44d 100644
--- a/net/x25/x25_proc.c
+++ b/net/x25/x25_proc.c
@@ -312,20 +312,18 @@ int __init x25_proc_init(void)
 	if (!x25_proc_dir)
 		goto out;
 
-	p = create_proc_entry("route", S_IRUGO, x25_proc_dir);
+	p = proc_create("route", S_IRUGO, x25_proc_dir, &x25_seq_route_fops);
 	if (!p)
 		goto out_route;
-	p->proc_fops = &x25_seq_route_fops;
 
-	p = create_proc_entry("socket", S_IRUGO, x25_proc_dir);
+	p = proc_create("socket", S_IRUGO, x25_proc_dir, &x25_seq_socket_fops);
 	if (!p)
 		goto out_socket;
-	p->proc_fops = &x25_seq_socket_fops;
 
-	p = create_proc_entry("forward", S_IRUGO, x25_proc_dir);
+	p = proc_create("forward", S_IRUGO, x25_proc_dir,
+			&x25_seq_forward_fops);
 	if (!p)
 		goto out_forward;
-	p->proc_fops = &x25_seq_forward_fops;
 	rc = 0;
 
 out:
-- 
WCN


