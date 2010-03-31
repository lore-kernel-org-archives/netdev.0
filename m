From: Tom Goff <thomas.goff@boeing.com>
Subject: [PATCH] net_sched: minor netns related cleanup
Date: Tue, 30 Mar 2010 19:43:54 -0700
Message-ID: <20100331024354.GA6631@boeing.com>
References: <20100326.201426.05866973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:41851 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653Ab0CaDJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 23:09:57 -0400
Content-Disposition: inline
In-Reply-To: <20100326.201426.05866973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes were suggested by Alexey Dobriyan <adobriyan@gmail.com>:

  - psched_show() does not use any private data so just pass NULL to
    psched_open()

  - remove unnecessary return statement

Signed-off-by: Tom Goff <thomas.goff@boeing.com>
---
 net/sched/sch_api.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6d6fe16..c65866d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1683,7 +1683,7 @@ static int psched_show(struct seq_file *seq, void *v)
 
 static int psched_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, psched_show, PDE(inode)->data);
+	return single_open(file, psched_show, NULL);
 }
 
 static const struct file_operations psched_fops = {
@@ -1708,8 +1708,6 @@ static int __net_init psched_net_init(struct net *net)
 static void __net_exit psched_net_exit(struct net *net)
 {
 	proc_net_remove(net, "psched");
-
-	return;
 }
 #else
 static int __net_init psched_net_init(struct net *net)
-- 
1.6.3.3

