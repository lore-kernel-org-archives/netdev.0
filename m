From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] security/selinux/netlabel.c: fix double free
Date: Tue, 29 Jan 2008 00:09:38 +0200
Message-ID: <20080128220938.GH8767@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: paul.moore@hp.com, James Morris <jmorris@namei.org>,
	sds@tycho.nsa.gov, eparis@parisplace.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758640AbYA1WJb@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a double free (security_netlbl_sid_to_secattr() already 
calls netlbl_secattr_destroy() when it returns !0) introduced by
commit 45c950e0f839fded922ebc0bfd59b1081cc71b70 and spotted by the 
Coverity checker.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
--- linux-2.6/security/selinux/netlabel.c.old	2008-01-23 00:38:19.000000000 +0200
+++ linux-2.6/security/selinux/netlabel.c	2008-01-23 00:39:09.000000000 +0200
@@ -58,22 +58,22 @@ static int selinux_netlbl_sock_setsid(st
 	rc = security_netlbl_sid_to_secattr(sid, &secattr);
 	if (rc != 0)
 		goto sock_setsid_return;
 	rc = netlbl_sock_setattr(sk, &secattr);
 	if (rc == 0) {
 		spin_lock_bh(&sksec->nlbl_lock);
 		sksec->nlbl_state = NLBL_LABELED;
 		spin_unlock_bh(&sksec->nlbl_lock);
 	}
 
-sock_setsid_return:
 	netlbl_secattr_destroy(&secattr);
+sock_setsid_return:
 	return rc;
 }
 
 /**
  * selinux_netlbl_cache_invalidate - Invalidate the NetLabel cache
  *
  * Description:
  * Invalidate the NetLabel security attribute mapping cache.
  *
  */
