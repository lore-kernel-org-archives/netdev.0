From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] addrconf: always initialize sysctl table data
Date: Mon, 21 Dec 2015 10:55:45 -0800
Message-ID: <1450724145-4777-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: sasha.levin@oracle.com, hannes@stressinduktion.org,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35118 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbbLUS4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 13:56:02 -0500
Received: by mail-pf0-f176.google.com with SMTP id 78so19891780pfw.2
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 10:56:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sysctl performs restrict writes, it allows to write from
a middle position of a sysctl file, which requires us to initialize
the table data before calling proc_dostring() for the write case.

Fixes: 3d1bec99320d ("ipv6: introduce secret_stable to ipv6_devconf")
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/addrconf.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 17f8e7e..1f21087 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5369,13 +5369,10 @@ static int addrconf_sysctl_stable_secret(struct ctl_table *ctl, int write,
 		goto out;
 	}
 
-	if (!write) {
-		err = snprintf(str, sizeof(str), "%pI6",
-			       &secret->secret);
-		if (err >= sizeof(str)) {
-			err = -EIO;
-			goto out;
-		}
+	err = snprintf(str, sizeof(str), "%pI6", &secret->secret);
+	if (err >= sizeof(str)) {
+		err = -EIO;
+		goto out;
 	}
 
 	err = proc_dostring(&lctl, write, buffer, lenp, ppos);
-- 
1.8.3.1
