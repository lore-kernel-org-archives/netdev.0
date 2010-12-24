From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] ceph: Always free allocated memory in osdmap_decode()
Date: Fri, 24 Dec 2010 23:01:12 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012242258160.28973@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sage Weil <sage@newdream.net>
To: ceph-devel@vger.kernel.org
Return-path: <ceph-devel-owner@vger.kernel.org>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Always free memory allocated to 'pi' in 
net/ceph/osdmap.c::osdmap_decode().

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 osdmap.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ceph/osdmap.c b/net/ceph/osdmap.c
index d73f3f6..71603ac 100644
--- a/net/ceph/osdmap.c
+++ b/net/ceph/osdmap.c
@@ -605,8 +605,10 @@ struct ceph_osdmap *osdmap_decode(void **p, void *end)
 			goto bad;
 		}
 		err = __decode_pool(p, end, pi);
-		if (err < 0)
+		if (err < 0) {
+			kfree(pi);
 			goto bad;
+		}
 		__insert_pg_pool(&map->pg_pools, pi);
 	}
 


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

