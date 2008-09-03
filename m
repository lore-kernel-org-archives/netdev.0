From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v4 12/14] netlabel: Changes to the NetLabel security
	attributes to allow LSMs to pass full contexts
Date: Tue, 02 Sep 2008 20:50:13 -0400
Message-ID: <20080903005013.15669.42041.stgit@flek.lan>
References: <20080903003647.15669.45349.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:14057 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939AbYICAuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:50:21 -0400
In-Reply-To: <20080903003647.15669.45349.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides support for including the LSM's secid in addition to
the LSM's MLS information in the NetLabel security attributes structure.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/net/netlabel.h         |    2 +-
 security/selinux/ss/services.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 074cad4..d56517a 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -203,7 +203,7 @@ struct netlbl_lsm_secattr {
 	u32 type;
 	char *domain;
 	struct netlbl_lsm_cache *cache;
-	union {
+	struct {
 		struct {
 			struct netlbl_lsm_secattr_catmap *cat;
 			u32 lvl;
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 5b7ecc1..ee91337 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -2806,7 +2806,8 @@ int security_netlbl_sid_to_secattr(u32 sid, struct netlbl_lsm_secattr *secattr)
 		rc = -ENOMEM;
 		goto netlbl_sid_to_secattr_failure;
 	}
-	secattr->flags |= NETLBL_SECATTR_DOMAIN_CPY;
+	secattr->attr.secid = sid;
+	secattr->flags |= NETLBL_SECATTR_DOMAIN_CPY | NETLBL_SECATTR_SECID;
 	mls_export_netlbl_lvl(ctx, secattr);
 	rc = mls_export_netlbl_cat(ctx, secattr);
 	if (rc != 0)

