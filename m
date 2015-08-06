From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 6/6] misc/ss: fix memory leak in user_ent_hash_build()
Date: Thu,  6 Aug 2015 14:24:36 +0200
Message-ID: <1438863876-1935-6-git-send-email-phil@nwl.cc>
References: <1438863876-1935-1-git-send-email-phil@nwl.cc>
 <1438863876-1935-2-git-send-email-phil@nwl.cc>
 <1438863876-1935-3-git-send-email-phil@nwl.cc>
 <1438863876-1935-4-git-send-email-phil@nwl.cc>
 <1438863876-1935-5-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53165 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755698AbbHFMYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 08:24:39 -0400
In-Reply-To: <1438863876-1935-5-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 0c7c6d7..bba7009 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -483,8 +483,10 @@ static void user_ent_hash_build(void)
 
 		sprintf(name + nameoff, "%d/fd/", pid);
 		pos = strlen(name);
-		if ((dir1 = opendir(name)) == NULL)
+		if ((dir1 = opendir(name)) == NULL) {
+			free(pid_context);
 			continue;
+		}
 
 		process[0] = '\0';
 		p = process;
-- 
2.1.2
