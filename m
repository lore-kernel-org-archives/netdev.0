From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 12/18] flag parametersi: NONBLOCK in anon_inode_getfd
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gkgJ029847@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756853AbYEEDnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building on the previous change to anon_inode_getfd, this patch introduces
support for handling of O_NONBLOCK in addition to the already supported
O_CLOEXEC.  Following patches will take advantage of this support.  As
can be seen, the additional support for supporting this functionality is
minimal.


 anon_inodes.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 977ef20..3662dd4 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -116,7 +116,7 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
 	file->f_mapping = anon_inode_inode->i_mapping;
 
 	file->f_pos = 0;
-	file->f_flags = O_RDWR;
+	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
 	file->f_version = 0;
 	file->private_data = priv;
 
