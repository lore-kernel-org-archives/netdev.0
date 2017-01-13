From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] afs: Conditionalise a new unused variable
Date: Fri, 13 Jan 2017 14:46:19 +0000
Message-ID: <148431877922.23745.3756091538832610041.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

The bulk readpages support introduced a harmless warning:

fs/afs/file.c: In function 'afs_readpages_page_done':
fs/afs/file.c:270:20: error: unused variable 'vnode' [-Werror=unused-variable]

This adds an #ifdef to match the user of that variable.  The user of the
variable has to be conditional because it accesses a member of a struct
that is also conditional.

Fixes: 91b467e0a3f5 ("afs: Make afs_readpages() fetch data in bulk")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/file.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/afs/file.c b/fs/afs/file.c
index 82897a78abc7..ba7b71fba34b 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -267,7 +267,9 @@ static int afs_readpage(struct file *file, struct page *page)
  */
 static void afs_readpages_page_done(struct afs_call *call, struct afs_read *req)
 {
+#ifdef CONFIG_AFS_FSCACHE
 	struct afs_vnode *vnode = call->reply;
+#endif
 	struct page *page = req->pages[req->index];
 
 	req->pages[req->index] = NULL;
