From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 1/2] SELinux: remove redundant pointer checks before calling kfree()
Date: Wed, 01 Aug 2007 11:12:58 -0400
Message-ID: <20070801151554.725968439@hp.com>
References: <20070801151257.475951538@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:41006 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757599AbXHAPYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 11:24:01 -0400
Content-Disposition: inline; filename=selinux-kfree_check
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't need to check for NULL pointers before calling kfree().

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/hooks.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6_secctx-leaks/security/selinux/hooks.c
===================================================================
--- linux-2.6_secctx-leaks.orig/security/selinux/hooks.c
+++ linux-2.6_secctx-leaks/security/selinux/hooks.c
@@ -4658,8 +4658,7 @@ static int selinux_secid_to_secctx(u32 s
 
 static void selinux_release_secctx(char *secdata, u32 seclen)
 {
-	if (secdata)
-		kfree(secdata);
+	kfree(secdata);
 }
 
 #ifdef CONFIG_KEYS

-- 
paul moore
linux security @ hp
