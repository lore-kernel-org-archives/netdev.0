From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 3/7] tipc: improve naming and comment
	consistency in media layer
Date: Tue, 10 Dec 2013 20:45:40 -0800
Message-ID: <1386737144-32334-4-git-send-email-jon.maloy@ericsson.com>
References: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1386737144-32334-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

struct 'tipc_media' represents the specific info that the media
layer adaptors (eth_media and ib_media) expose to the generic
bearer layer. We clarify this by improved commenting, and by giving
the 'media_list' array the more appropriate name 'media_info_array'.

There are no functional changes in this commit.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c |   32 ++++++++++++++++----------------
 net/tipc/bearer.h |    6 +++---
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 826aa9f..2411bac 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -41,7 +41,7 @@
 
 #define MAX_ADDR_STR 60
 
-static struct tipc_media * const media_list[] = {
+static struct tipc_media * const media_info_array[] = {
 	&eth_media_info,
 #ifdef CONFIG_TIPC_MEDIA_IB
 	&ib_media_info,
@@ -60,11 +60,11 @@ struct tipc_media *tipc_media_find(const char *name)
 {
 	u32 i;
 
-	for (i = 0; media_list[i] != NULL; i++) {
-		if (!strcmp(media_list[i]->name, name))
+	for (i = 0; media_info_array[i] != NULL; i++) {
+		if (!strcmp(media_info_array[i]->name, name))
 			break;
 	}
-	return media_list[i];
+	return media_info_array[i];
 }
 
 /**
@@ -74,11 +74,11 @@ static struct tipc_media *media_find_id(u8 type)
 {
 	u32 i;
 
-	for (i = 0; media_list[i] != NULL; i++) {
-		if (media_list[i]->type_id == type)
+	for (i = 0; media_info_array[i] != NULL; i++) {
+		if (media_info_array[i]->type_id == type)
 			break;
 	}
-	return media_list[i];
+	return media_info_array[i];
 }
 
 /**
@@ -116,10 +116,10 @@ struct sk_buff *tipc_media_get_names(void)
 	if (!buf)
 		return NULL;
 
-	for (i = 0; media_list[i] != NULL; i++) {
+	for (i = 0; media_info_array[i] != NULL; i++) {
 		tipc_cfg_append_tlv(buf, TIPC_TLV_MEDIA_NAME,
-				    media_list[i]->name,
-				    strlen(media_list[i]->name) + 1);
+				    media_info_array[i]->name,
+				    strlen(media_info_array[i]->name) + 1);
 	}
 	return buf;
 }
@@ -209,7 +209,7 @@ struct tipc_bearer *tipc_bearer_find_interface(const char *if_name)
 struct sk_buff *tipc_bearer_get_names(void)
 {
 	struct sk_buff *buf;
-	struct tipc_bearer *b_ptr;
+	struct tipc_bearer *b;
 	int i, j;
 
 	buf = tipc_cfg_reply_alloc(MAX_BEARERS * TLV_SPACE(TIPC_MAX_BEARER_NAME));
@@ -217,13 +217,13 @@ struct sk_buff *tipc_bearer_get_names(void)
 		return NULL;
 
 	read_lock_bh(&tipc_net_lock);
-	for (i = 0; media_list[i] != NULL; i++) {
+	for (i = 0; media_info_array[i] != NULL; i++) {
 		for (j = 0; j < MAX_BEARERS; j++) {
-			b_ptr = &tipc_bearers[j];
-			if (b_ptr->active && (b_ptr->media == media_list[i])) {
+			b = &tipc_bearers[j];
+			if (b->active && (b->media == media_info_array[i])) {
 				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
-						    b_ptr->name,
-						    strlen(b_ptr->name) + 1);
+						    b->name,
+						    strlen(b->name) + 1);
 			}
 		}
 	}
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 516af8c05..e50266a 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -73,14 +73,13 @@ struct tipc_media_addr {
 struct tipc_bearer;
 
 /**
- * struct tipc_media - TIPC media information available to internal users
+ * struct tipc_media - Media specific info exposed to generic bearer layer
  * @send_msg: routine which handles buffer transmission
  * @enable_media: routine which enables a media
  * @disable_media: routine which disables a media
  * @addr2str: routine which converts media address to string
  * @addr2msg: routine which converts media address to protocol message area
  * @msg2addr: routine which converts media address from protocol message area
- * @bcast_addr: media address used in broadcasting
  * @priority: default link (and bearer) priority
  * @tolerance: default time (in ms) before declaring link failure
  * @window: default window (in packets) before declaring link congestion
@@ -105,13 +104,14 @@ struct tipc_media {
 };
 
 /**
- * struct tipc_bearer - TIPC bearer structure
+ * struct tipc_bearer - Generic TIPC bearer structure
  * @usr_handle: pointer to additional media-specific information about bearer
  * @mtu: max packet size bearer can support
  * @lock: spinlock for controlling access to bearer
  * @addr: media-specific address associated with bearer
  * @name: bearer name (format = media:interface)
  * @media: ptr to media structure associated with bearer
+ * @bcast_addr: media address used in broadcasting
  * @priority: default link priority for bearer
  * @window: default window size for bearer
  * @tolerance: default link tolerance for bearer
-- 
1.7.9.5


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
