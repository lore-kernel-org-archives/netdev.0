From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 05/15] [IPX]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:56:23 +0800
Message-ID: <47C69357.1050803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49524 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbYB1K6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:58:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipx/ipx_proc.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
index d483a00..5ed97ad 100644
--- a/net/ipx/ipx_proc.c
+++ b/net/ipx/ipx_proc.c
@@ -358,22 +358,19 @@ int __init ipx_proc_init(void)
 
 	if (!ipx_proc_dir)
 		goto out;
-	p = create_proc_entry("interface", S_IRUGO, ipx_proc_dir);
+	p = proc_create("interface", S_IRUGO,
+			ipx_proc_dir, &ipx_seq_interface_fops);
 	if (!p)
 		goto out_interface;
 
-	p->proc_fops = &ipx_seq_interface_fops;
-	p = create_proc_entry("route", S_IRUGO, ipx_proc_dir);
+	p = proc_create("route", S_IRUGO, ipx_proc_dir, &ipx_seq_route_fops);
 	if (!p)
 		goto out_route;
 
-	p->proc_fops = &ipx_seq_route_fops;
-	p = create_proc_entry("socket", S_IRUGO, ipx_proc_dir);
+	p = proc_create("socket", S_IRUGO, ipx_proc_dir, &ipx_seq_socket_fops);
 	if (!p)
 		goto out_socket;
 
-	p->proc_fops = &ipx_seq_socket_fops;
-
 	rc = 0;
 out:
 	return rc;
-- 
WCN


