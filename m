From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 02/15] userns: Make credential debugging user namespace safe.
Date: Sat, 25 Aug 2012 16:59:04 -0700
Message-ID: <877gsmh6bb.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: David Howells <dhowells@redhat.com>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Cc: David Howells <dhowells@redhat.com>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 init/Kconfig  |    1 -
 kernel/cred.c |   10 ++++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 448b701..fdabc51 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -936,7 +936,6 @@ config UIDGID_CONVERTED
 	depends on FS_POSIX_ACL = n
 	depends on QUOTA = n
 	depends on QUOTACTL = n
-	depends on DEBUG_CREDENTIALS = n
 	depends on BSD_PROCESS_ACCT = n
 	depends on DRM = n
 	depends on PROC_EVENTS = n
diff --git a/kernel/cred.c b/kernel/cred.c
index de728ac..48cea3d 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -799,9 +799,15 @@ static void dump_invalid_creds(const struct cred *cred, const char *label,
 	       atomic_read(&cred->usage),
 	       read_cred_subscribers(cred));
 	printk(KERN_ERR "CRED: ->*uid = { %d,%d,%d,%d }\n",
-	       cred->uid, cred->euid, cred->suid, cred->fsuid);
+		from_kuid_munged(&init_user_ns, cred->uid),
+		from_kuid_munged(&init_user_ns, cred->euid),
+		from_kuid_munged(&init_user_ns, cred->suid),
+		from_kuid_munged(&init_user_ns, cred->fsuid));
 	printk(KERN_ERR "CRED: ->*gid = { %d,%d,%d,%d }\n",
-	       cred->gid, cred->egid, cred->sgid, cred->fsgid);
+		from_kgid_munged(&init_user_ns, cred->gid),
+		from_kgid_munged(&init_user_ns, cred->egid),
+		from_kgid_munged(&init_user_ns, cred->sgid),
+		from_kgid_munged(&init_user_ns, cred->fsgid));
 #ifdef CONFIG_SECURITY
 	printk(KERN_ERR "CRED: ->security is %p\n", cred->security);
 	if ((unsigned long) cred->security >= PAGE_SIZE &&
-- 
1.7.5.4
