From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v5 12/14] netlabel: Changes to the NetLabel security
	attributes to allow LSMs to pass full contexts
Date: Fri, 05 Sep 2008 19:24:35 -0400
Message-ID: <20080905232435.31840.27163.stgit@flek.lan>
References: <20080905231853.31840.57880.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080905231853.31840.57880.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides support for including the LSM's secid in addition to
the LSM's MLS information in the NetLabel security attributes structure.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Acked-by: James Morris <jmorris@namei.org>
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
index 8d17dfb..ed0b00b 100644
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

