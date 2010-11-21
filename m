From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] m_xt: stop using xtables_set_revision()
Date: Sun, 21 Nov 2010 16:16:54 -0500
Message-ID: <1290374214-26743-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59207 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754578Ab0KUVTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Nov 2010 16:19:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iptables dropped the xtables_set_revision() function around version 1.4.9,
so set the rev directly ourselves.  This should be compatible back to the
original version m_xt itself is designed for.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tc/m_xt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index bfc4937..ede9913 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -88,7 +88,7 @@ build_st(struct xtables_target *target, struct xt_entry_target *t)
 		target->t = xtables_calloc(1, size);
 		target->t->u.target_size = size;
 		strcpy(target->t->u.user.name, target->name);
-		xtables_set_revision(target->t->u.user.name, target->revision);
+		target->t->u.user.revision = target->revision;
 
 		if (target->init != NULL)
 			target->init(target->t);
-- 
1.7.3.1

