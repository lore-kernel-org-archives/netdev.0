From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] team: lb: use sizeof(*fprog) in __fprog_create
Date: Sat, 24 May 2014 21:47:46 +0200
Message-ID: <1400960866-14450-1-git-send-email-dborkman@redhat.com>
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236AbaEXTru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 May 2014 15:47:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_fprog and sock_fprog_kern are of equal size, however
it's cleaner to just use sizeof(*fprog) instead to always
have correct type.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/team/team_mode_loadbalance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 0a6ee07..a58dfeb 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -249,7 +249,7 @@ static int __fprog_create(struct sock_fprog_kern **pfprog, u32 data_len,
 
 	if (data_len % sizeof(struct sock_filter))
 		return -EINVAL;
-	fprog = kmalloc(sizeof(struct sock_fprog), GFP_KERNEL);
+	fprog = kmalloc(sizeof(*fprog), GFP_KERNEL);
 	if (!fprog)
 		return -ENOMEM;
 	fprog->filter = kmemdup(filter, data_len, GFP_KERNEL);
-- 
1.7.11.7
