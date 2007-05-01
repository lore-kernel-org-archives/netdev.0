From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AFS: Fix use of __exit functions from __init path
Date: Tue, 01 May 2007 19:17:06 +0100
Message-ID: <20070501181706.28008.10566.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, geert@linux-m68k.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030608AbXEASRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 14:17:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix use of __exit functions from __init path.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/callback.c  |    2 +-
 fs/afs/internal.h  |    4 ++--
 fs/afs/vlocation.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/afs/callback.c b/fs/afs/callback.c
index 639399f..9bdbf36 100644
--- a/fs/afs/callback.c
+++ b/fs/afs/callback.c
@@ -468,7 +468,7 @@ int __init afs_callback_update_init(void)
 /*
  * shut down the callback update process
  */
-void __exit afs_callback_update_kill(void)
+void afs_callback_update_kill(void)
 {
 	destroy_workqueue(afs_callback_update_worker);
 }
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index c0404b4..f1bd47e 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -401,7 +401,7 @@ extern void afs_give_up_callback(struct afs_vnode *);
 extern void afs_dispatch_give_up_callbacks(struct work_struct *);
 extern void afs_flush_callback_breaks(struct afs_server *);
 extern int __init afs_callback_update_init(void);
-extern void __exit afs_callback_update_kill(void);
+extern void afs_callback_update_kill(void);
 
 /*
  * cell.c
@@ -605,7 +605,7 @@ extern struct afs_vlocation *afs_vlocation_lookup(struct afs_cell *,
 						  struct key *,
 						  const char *, size_t);
 extern void afs_put_vlocation(struct afs_vlocation *);
-extern void __exit afs_vlocation_purge(void);
+extern void afs_vlocation_purge(void);
 
 /*
  * vnode.c
diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index 6c8e95a..3370cdb 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -602,7 +602,7 @@ int __init afs_vlocation_update_init(void)
 /*
  * discard all the volume location records for rmmod
  */
-void __exit afs_vlocation_purge(void)
+void afs_vlocation_purge(void)
 {
 	afs_vlocation_timeout = 0;
 

