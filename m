From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too long
Date: Tue, 19 Mar 2013 20:47:27 +0900
Message-ID: <1363693648-10015-2-git-send-email-yamato@redhat.com>
References: <1363693648-10015-1-git-send-email-yamato@redhat.com>
Cc: Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h219-110-095-248.catv01.itscom.jp ([219.110.95.248]:55726 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932964Ab3CSR2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:28:33 -0400
In-Reply-To: <1363693648-10015-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/netlink/genetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f2aabb6..5a55be3 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -142,6 +142,7 @@ int genl_register_mc_group(struct genl_family *family,
 	int err = 0;
 
 	BUG_ON(grp->name[0] == '\0');
+	BUG_ON(memchr(grp->name, '\0', GENL_NAMSIZ) == NULL);
 
 	genl_lock();
 
-- 
1.7.11.7
