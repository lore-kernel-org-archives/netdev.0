From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 1/4] afs: unmapping the wrong buffer
Date: Thu, 13 Oct 2016 17:12:17 +0100
Message-ID: <147637513708.17348.15850582249955166756.stgit@warthog.procyon.org.uk>
References: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        dan.carpenter@oracle.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755258AbcJMQWg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 12:22:36 -0400
In-Reply-To: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

We switched from kmap_atomic() to kmap() so the kunmap() calls need to
be updated to match.

Fixes: d001648ec7cf ('rxrpc: Don't expose skbs to in-kernel users [ver #2]')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/fsclient.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 96f4d764d1a6..31c616ab9b40 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -364,7 +364,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call)
 			buffer = kmap(page);
 			ret = afs_extract_data(call, buffer,
 					       call->count, true);
-			kunmap(buffer);
+			kunmap(page);
 			if (ret < 0)
 				return ret;
 		}
@@ -397,7 +397,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call)
 		page = call->reply3;
 		buffer = kmap(page);
 		memset(buffer + call->count, 0, PAGE_SIZE - call->count);
-		kunmap(buffer);
+		kunmap(page);
 	}
 
 	_leave(" = 0 [done]");
