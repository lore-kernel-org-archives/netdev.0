From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 12/15] [IPV4]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:58:06 +0800
Message-ID: <47C693BE.10302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52801 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756440AbYB1LAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 06:00:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv4/route.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 525787b..7b5e8e1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -542,12 +542,11 @@ static __init int ip_rt_proc_init(struct net *net)
 	if (!pde)
 		goto err1;
 
-	pde = create_proc_entry("rt_cache", S_IRUGO, net->proc_net_stat);
+	pde = proc_create("rt_cache", S_IRUGO,
+			  net->proc_net_stat, &rt_cpu_seq_fops);
 	if (!pde)
 		goto err2;
 
-	pde->proc_fops = &rt_cpu_seq_fops;
-
 #ifdef CONFIG_NET_CLS_ROUTE
 	pde = create_proc_read_entry("rt_acct", 0, net->proc_net,
 			ip_rt_acct_read, NULL);
-- 
WCN


