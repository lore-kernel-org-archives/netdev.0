From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 15/15] userns: Convert configfs to use kuid and kgid where appropriate
Date: Sat, 25 Aug 2012 17:07:14 -0700
Message-ID: <874nnqecst.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Cc: Joel Becker <jlbec@evilplan.org>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Cc: Joel Becker <jlbec@evilplan.org>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/configfs/inode.c |    4 ++--
 init/Kconfig        |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/configfs/inode.c b/fs/configfs/inode.c
index 0074362..a9d35b0 100644
--- a/fs/configfs/inode.c
+++ b/fs/configfs/inode.c
@@ -79,8 +79,8 @@ int configfs_setattr(struct dentry * dentry, struct iattr * iattr)
 			return -ENOMEM;
 		/* assign default attributes */
 		sd_iattr->ia_mode = sd->s_mode;
-		sd_iattr->ia_uid = 0;
-		sd_iattr->ia_gid = 0;
+		sd_iattr->ia_uid = GLOBAL_ROOT_UID;
+		sd_iattr->ia_gid = GLOBAL_ROOT_GID;
 		sd_iattr->ia_atime = sd_iattr->ia_mtime = sd_iattr->ia_ctime = CURRENT_TIME;
 		sd->s_iattr = sd_iattr;
 	}
diff --git a/init/Kconfig b/init/Kconfig
index e8612fb..296d48b 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -948,7 +948,6 @@ config UIDGID_CONVERTED
 	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
-	depends on CONFIGFS_FS = n
 	depends on CRAMFS = n
 	depends on ECRYPT_FS = n
 	depends on EFS_FS = n
-- 
1.7.5.4

