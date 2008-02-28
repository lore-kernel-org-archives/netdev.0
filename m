From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 07/15] [LLC]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:56:54 +0800
Message-ID: <47C69376.9030303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52517 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754639AbYB1K7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:59:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/llc/llc_proc.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index cb34bc0..48212c0 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -239,18 +239,14 @@ int __init llc_proc_init(void)
 		goto out;
 	llc_proc_dir->owner = THIS_MODULE;
 
-	p = create_proc_entry("socket", S_IRUGO, llc_proc_dir);
+	p = proc_create("socket", S_IRUGO, llc_proc_dir, &llc_seq_socket_fops);
 	if (!p)
 		goto out_socket;
 
-	p->proc_fops = &llc_seq_socket_fops;
-
-	p = create_proc_entry("core", S_IRUGO, llc_proc_dir);
+	p = proc_create("core", S_IRUGO, llc_proc_dir, &llc_seq_core_fops);
 	if (!p)
 		goto out_core;
 
-	p->proc_fops = &llc_seq_core_fops;
-
 	rc = 0;
 out:
 	return rc;
-- 
WCN


