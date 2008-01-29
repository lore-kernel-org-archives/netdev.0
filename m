From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] SELinux: Fix double free in selinux_netlbl_sock_setsid()
Date: Mon, 28 Jan 2008 21:20:26 -0500
Message-ID: <20080129022026.7930.18782.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, stable@kernel.org,
	bunk@kernel.org, jmorris@namei.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762280AbYA2CV0@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As pointed out by Adrian Bunk, commit 45c950e0f839fded922ebc0bfd59b1081cc71b70
caused a double-free when security_netlbl_sid_to_secattr() fails.  This patch
fixes this by removing the netlbl_secattr_destroy() call from that function
since we are already releasing the secattr memory in
selinux_netlbl_sock_setsid().

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 security/selinux/ss/services.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 4bf715d..3a16aba 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -2629,7 +2629,6 @@ int security_netlbl_sid_to_secattr(u32 sid, struct netlbl_lsm_secattr *secattr)
 
 netlbl_sid_to_secattr_failure:
 	POLICY_RDUNLOCK;
-	netlbl_secattr_destroy(secattr);
 	return rc;
 }
 #endif /* CONFIG_NETLABEL */
