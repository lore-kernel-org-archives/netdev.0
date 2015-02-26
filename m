From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 4/5] tipc: rename media/msg
	related definitions
Date: Thu, 26 Feb 2015 07:43:29 +0100
Message-ID: <1424933010-31003-5-git-send-email-erik.hugne@ericsson.com>
References: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

The TIPC_MEDIA_ADDR_SIZE and TIPC_MEDIA_ADDR_OFFSET names
are misleading, as they actually define the size and offset of
the whole media info field and not the address part. This patch
does not have any functional changes.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bearer.h    | 4 ++--
 net/tipc/eth_media.c | 2 +-
 net/tipc/ib_media.c  | 2 +-
 net/tipc/msg.h       | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 6b17795..1a23327 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -50,7 +50,7 @@
  * - the field's actual content and length is defined per media
  * - remaining unused bytes in the field are set to zero
  */
-#define TIPC_MEDIA_ADDR_SIZE	32
+#define TIPC_MEDIA_INFO_SIZE	32
 #define TIPC_MEDIA_TYPE_OFFSET	3
 
 /*
@@ -76,7 +76,7 @@ struct tipc_node_map {
  * @broadcast: non-zero if address is a broadcast address
  */
 struct tipc_media_addr {
-	u8 value[TIPC_MEDIA_ADDR_SIZE];
+	u8 value[TIPC_MEDIA_INFO_SIZE];
 	u8 media_id;
 	u8 broadcast;
 };
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 5e1426f..085d3a0 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -53,7 +53,7 @@ static int tipc_eth_addr2str(struct tipc_media_addr *addr,
 /* Convert from media address format to discovery message addr format */
 static int tipc_eth_addr2msg(char *msg, struct tipc_media_addr *addr)
 {
-	memset(msg, 0, TIPC_MEDIA_ADDR_SIZE);
+	memset(msg, 0, TIPC_MEDIA_INFO_SIZE);
 	msg[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_ETH;
 	memcpy(msg + ETH_ADDR_OFFSET, addr->value, ETH_ALEN);
 	return 0;
diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index 8522eef..e8c1671 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -57,7 +57,7 @@ static int tipc_ib_addr2str(struct tipc_media_addr *a, char *str_buf,
 /* Convert from media address format to discovery message addr format */
 static int tipc_ib_addr2msg(char *msg, struct tipc_media_addr *addr)
 {
-	memset(msg, 0, TIPC_MEDIA_ADDR_SIZE);
+	memset(msg, 0, TIPC_MEDIA_INFO_SIZE);
 	memcpy(msg, addr->value, INFINIBAND_ALEN);
 	return 0;
 }
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 9ace47f..c1cc8d7 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -76,7 +76,7 @@ struct plist;
 
 #define MAX_MSG_SIZE (MAX_H_SIZE + TIPC_MAX_USER_MSG_SIZE)
 
-#define TIPC_MEDIA_ADDR_OFFSET	5
+#define TIPC_MEDIA_INFO_OFFSET	5
 
 /**
  * TIPC message buffer code
@@ -688,7 +688,7 @@ static inline void msg_set_redundant_link(struct tipc_msg *m, u32 r)
 
 static inline char *msg_media_addr(struct tipc_msg *m)
 {
-	return (char *)&m->hdr[TIPC_MEDIA_ADDR_OFFSET];
+	return (char *)&m->hdr[TIPC_MEDIA_INFO_OFFSET];
 }
 
 /*
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
