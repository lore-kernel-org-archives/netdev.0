From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 1/6] ip/ipnetns: prevent potential string buffer overflow
Date: Thu,  6 Aug 2015 14:24:31 +0200
Message-ID: <1438863876-1935-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38069 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755678AbbHFMYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 08:24:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipnetns.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 3b704a4..32b0f51 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -178,7 +178,8 @@ static int netns_map_add(int nsid, char *name)
 		return -ENOMEM;
 	}
 	c->nsid = nsid;
-	strcpy(c->name, name);
+	strncpy(c->name, name, NAME_MAX);
+	c->name[NAME_MAX - 1] = '\0';
 
 	h = NSID_HASH_NSID(nsid);
 	hlist_add_head(&c->nsid_hash, &nsid_head[h]);
-- 
2.1.2
