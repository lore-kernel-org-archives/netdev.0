From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: [PATCH 1/5] tipc: remove unused str2addr media callback
Date: Wed, 17 Apr 2013 18:18:25 +0200
Message-ID: <1366215509-18500-2-git-send-email-kaber@trash.net>
References: <1366215509-18500-1-git-send-email-kaber@trash.net>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1366215509-18500-1-git-send-email-kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
---
 net/tipc/bearer.h    |  2 --
 net/tipc/eth_media.c | 20 --------------------
 2 files changed, 22 deletions(-)

diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 39f1192..cc2d74e 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -77,7 +77,6 @@ struct tipc_bearer;
  * @enable_bearer: routine which enables a bearer
  * @disable_bearer: routine which disables a bearer
  * @addr2str: routine which converts media address to string
- * @str2addr: routine which converts media address from string
  * @addr2msg: routine which converts media address to protocol message area
  * @msg2addr: routine which converts media address from protocol message area
  * @bcast_addr: media address used in broadcasting
@@ -94,7 +93,6 @@ struct tipc_media {
 	int (*enable_bearer)(struct tipc_bearer *b_ptr);
 	void (*disable_bearer)(struct tipc_bearer *b_ptr);
 	int (*addr2str)(struct tipc_media_addr *a, char *str_buf, int str_size);
-	int (*str2addr)(struct tipc_media_addr *a, char *str_buf);
 	int (*addr2msg)(struct tipc_media_addr *a, char *msg_area);
 	int (*msg2addr)(struct tipc_media_addr *a, char *msg_area);
 	struct tipc_media_addr bcast_addr;
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 2132c1e..1bdc6df 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -302,25 +302,6 @@ static int eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 }
 
 /**
- * eth_str2addr - convert string to Ethernet address
- */
-static int eth_str2addr(struct tipc_media_addr *a, char *str_buf)
-{
-	char mac[ETH_ALEN];
-	int r;
-
-	r = sscanf(str_buf, "%02x:%02x:%02x:%02x:%02x:%02x",
-		       (u32 *)&mac[0], (u32 *)&mac[1], (u32 *)&mac[2],
-		       (u32 *)&mac[3], (u32 *)&mac[4], (u32 *)&mac[5]);
-
-	if (r != ETH_ALEN)
-		return 1;
-
-	eth_media_addr_set(a, mac);
-	return 0;
-}
-
-/**
  * eth_str2addr - convert Ethernet address format to message header format
  */
 static int eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
@@ -351,7 +332,6 @@ static struct tipc_media eth_media_info = {
 	.enable_bearer	= enable_bearer,
 	.disable_bearer	= disable_bearer,
 	.addr2str	= eth_addr2str,
-	.str2addr	= eth_str2addr,
 	.addr2msg	= eth_addr2msg,
 	.msg2addr	= eth_msg2addr,
 	.bcast_addr	= { { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
