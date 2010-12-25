From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Ceph: Fix a use-after-free bug in ceph_destroy_client().
Date: Sat, 25 Dec 2010 19:17:02 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012251914370.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sage Weil <sage@newdream.net>,
	"David S. Miller" <davem@davemloft.net>
To: ceph-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

In net/ceph/ceph_common.c::ceph_destroy_client() the pointer 'client' is 
freed by kfree() and subsequently used in a call to dout() - use after 
free bug.
Easily fixed by simply moving the kfree() call after the dout() call.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 ceph_common.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index f3e4a13..890bbbf 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -408,8 +408,8 @@ void ceph_destroy_client(struct ceph_client *client)
 
 	ceph_destroy_options(client->options);
 
-	kfree(client);
 	dout("destroy_client %p done\n", client);
+	kfree(client);
 }
 EXPORT_SYMBOL(ceph_destroy_client);
 

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
