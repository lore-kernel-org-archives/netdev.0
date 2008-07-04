From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 08/15] sysfs: Make sysfs_mount static once again.
Date: Thu, 03 Jul 2008 18:14:36 -0700
Message-ID: <m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<m1ej6enep7.fsf@frodo.ebiederm.org> <486A0751.9080602@gmail.com>
	<m1wsk5hjm0.fsf@frodo.ebiederm.org> <486AF4FA.8020805@gmail.com>
	<m1ej6d9c2r.fsf@frodo.ebiederm.org> <486B060C.7030607@gmail.com>
	<m14p78s02q.fsf@frodo.ebiederm.org> <486C4515.1070007@gmail.com>
	<m1hcb7o8lv.fsf@frodo.ebiederm.org> <486CB051.5000507@fr.ibm.com>
	<m14p77m9uy.fsf@frodo.ebiederm.org> <486CF71F.5090405@gmail.com>
	<m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>
	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>
	<m1d4luihea.fsf_-_@frodo.ebiederm.org>
	<m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>, Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	<netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57921 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbYGDBVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 21:21:45 -0400
In-Reply-To: <m14p76ih9a.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 03 Jul 2008 18:13:05 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Accessing the internal sysfs_mount is error prone in the context
of multiple super blocks, and nothing needs it.  Not even the
sysfs crash debugging patch (although it did in an earlier version).

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/mount.c |    2 +-
 fs/sysfs/sysfs.h |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index c812cc4..99974f0 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -22,7 +22,7 @@
 /* Random magic number */
 #define SYSFS_MAGIC 0x62656572
 
-struct vfsmount *sysfs_mount;
+static struct vfsmount *sysfs_mount;
 struct super_block * sysfs_sb = NULL;
 struct kmem_cache *sysfs_dir_cachep;
 
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 5ee5d0a..33b3c73 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -97,7 +97,6 @@ struct sysfs_super_info {
 extern struct sysfs_dirent sysfs_root;
 extern struct super_block *sysfs_sb;
 extern struct kmem_cache *sysfs_dir_cachep;
-extern struct vfsmount *sysfs_mount;
 extern struct file_system_type sysfs_fs_type;
 
 void sysfs_grab_supers(void);
-- 
1.5.3.rc6.17.g1911

