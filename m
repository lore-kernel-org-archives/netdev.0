From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] tipc: Use pr_fmt
Date: Thu, 12 Jul 2012 10:51:21 -0700
Message-ID: <1342115481.13046.5.camel@joe2Laptop>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:56584 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932781Ab2GLRvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 13:51:23 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove embedded "TIPC: " prefix from pr_<level> uses.
Add '#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt' to core.h
Make sure core.h is the first include in all .c files.

This changes the prefix from "TIPC: " to "tipc: "

Other miscellaneous changes in link.c to coalesce multiple
pr_info uses without newlines to single pr_info output.

Align a few arguments to open parenthesis as well.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Thu, 2012-07-12 at 12:39 -0400, Paul Gortmaker wrote:

> The main thrust of what happens in this series is to deal with
> the request you'd made a while ago about making it so TIPC did
> not have its own specific (and complex) logging infrastructure.

Excellent.

How about extending this to use the more common pr_fmt prefix?

 net/tipc/bcast.c       |    2 +-
 net/tipc/bearer.c      |   34 ++++++++++++++--------------
 net/tipc/config.c      |    6 ++--
 net/tipc/core.c        |   11 ++++-----
 net/tipc/core.h        |    2 +
 net/tipc/discover.c    |    2 +-
 net/tipc/handler.c     |    4 +-
 net/tipc/link.c        |   57 ++++++++++++++++++++++++-----------------------
 net/tipc/name_distr.c  |   12 +++++-----
 net/tipc/name_table.c  |   22 +++++++++---------
 net/tipc/net.c         |    6 ++--
 net/tipc/netlink.c     |    2 +-
 net/tipc/node.c        |   17 ++++++-------
 net/tipc/node_subscr.c |    2 +-
 net/tipc/port.c        |    8 +++---
 net/tipc/ref.c         |   10 ++++----
 net/tipc/socket.c      |   10 ++++----
 net/tipc/subscr.c      |   12 +++++-----
 18 files changed, 110 insertions(+), 109 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 5b84337..e4e6d8c 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -875,7 +875,7 @@ void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port)
 		if (!item->next) {
 			item->next = kmalloc(sizeof(*item), GFP_ATOMIC);
 			if (!item->next) {
-				pr_warn("TIPC: Incomplete multicast delivery, no memory\n");
+				pr_warn("Incomplete multicast delivery, no memory\n");
 				return;
 			}
 			item->next->next = NULL;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 1186413..09e7124 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -123,7 +123,7 @@ int tipc_register_media(struct tipc_media *m_ptr)
 exit:
 	write_unlock_bh(&tipc_net_lock);
 	if (res)
-		pr_warn("TIPC: Media <%s> registration error\n", m_ptr->name);
+		pr_warn("Media <%s> registration error\n", m_ptr->name);
 	return res;
 }
 
@@ -420,12 +420,12 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 	int res = -EINVAL;
 
 	if (!tipc_own_addr) {
-		pr_warn("TIPC: Bearer <%s> rejected, not supported in standalone mode\n",
+		pr_warn("Bearer <%s> rejected, not supported in standalone mode\n",
 			name);
 		return -ENOPROTOOPT;
 	}
 	if (!bearer_name_validate(name, &b_names)) {
-		pr_warn("TIPC: Bearer <%s> rejected, illegal name\n", name);
+		pr_warn("Bearer <%s> rejected, illegal name\n", name);
 		return -EINVAL;
 	}
 	if (tipc_addr_domain_valid(disc_domain) &&
@@ -437,13 +437,13 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 			res = 0;   /* accept specified node in own cluster */
 	}
 	if (res) {
-		pr_warn("TIPC: Bearer <%s> rejected, illegal discovery domain\n",
+		pr_warn("Bearer <%s> rejected, illegal discovery domain\n",
 			name);
 		return -EINVAL;
 	}
 	if ((priority > TIPC_MAX_LINK_PRI) &&
 	    (priority != TIPC_MEDIA_LINK_PRI)) {
-		pr_warn("TIPC: Bearer <%s> rejected, illegal priority\n", name);
+		pr_warn("Bearer <%s> rejected, illegal priority\n", name);
 		return -EINVAL;
 	}
 
@@ -451,7 +451,7 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 
 	m_ptr = tipc_media_find(b_names.media_name);
 	if (!m_ptr) {
-		pr_warn("TIPC: Bearer <%s> rejected, media <%s> not registered\n",
+		pr_warn("Bearer <%s> rejected, media <%s> not registered\n",
 			name, b_names.media_name);
 		goto exit;
 	}
@@ -468,24 +468,24 @@ restart:
 			continue;
 		}
 		if (!strcmp(name, tipc_bearers[i].name)) {
-			pr_warn("TIPC: Bearer <%s> rejected, already enabled\n",
+			pr_warn("Bearer <%s> rejected, already enabled\n",
 				name);
 			goto exit;
 		}
 		if ((tipc_bearers[i].priority == priority) &&
 		    (++with_this_prio > 2)) {
 			if (priority-- == 0) {
-				pr_warn("TIPC: Bearer <%s> rejected, duplicate priority\n",
+				pr_warn("Bearer <%s> rejected, duplicate priority\n",
 					name);
 				goto exit;
 			}
-			pr_warn("TIPC: Bearer <%s> priority adjustment required %u->%u\n",
+			pr_warn("Bearer <%s> priority adjustment required %u->%u\n",
 				name, priority + 1, priority);
 			goto restart;
 		}
 	}
 	if (bearer_id >= MAX_BEARERS) {
-		pr_warn("TIPC: Bearer <%s> rejected, bearer limit reached (%u)\n",
+		pr_warn("Bearer <%s> rejected, bearer limit reached (%u)\n",
 			name, MAX_BEARERS);
 		goto exit;
 	}
@@ -494,7 +494,7 @@ restart:
 	strcpy(b_ptr->name, name);
 	res = m_ptr->enable_bearer(b_ptr);
 	if (res) {
-		pr_warn("TIPC: Bearer <%s> rejected, enable failure (%d)\n",
+		pr_warn("Bearer <%s> rejected, enable failure (%d)\n",
 			name, -res);
 		goto exit;
 	}
@@ -513,11 +513,11 @@ restart:
 	res = tipc_disc_create(b_ptr, &m_ptr->bcast_addr, disc_domain);
 	if (res) {
 		bearer_disable(b_ptr);
-		pr_warn("TIPC: Bearer <%s> rejected, discovery object creation failed\n",
+		pr_warn("Bearer <%s> rejected, discovery object creation failed\n",
 			name);
 		goto exit;
 	}
-	pr_info("TIPC: Enabled bearer <%s>, discovery domain %s, priority %u\n",
+	pr_info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
 		name,
 		tipc_addr_string_fill(addr_string, disc_domain), priority);
 exit:
@@ -537,12 +537,12 @@ int tipc_block_bearer(const char *name)
 	read_lock_bh(&tipc_net_lock);
 	b_ptr = tipc_bearer_find(name);
 	if (!b_ptr) {
-		pr_warn("TIPC: Attempt to block unknown bearer <%s>\n", name);
+		pr_warn("Attempt to block unknown bearer <%s>\n", name);
 		read_unlock_bh(&tipc_net_lock);
 		return -EINVAL;
 	}
 
-	pr_info("TIPC: Blocking bearer <%s>\n", name);
+	pr_info("Blocking bearer <%s>\n", name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
 	list_splice_init(&b_ptr->cong_links, &b_ptr->links);
@@ -568,7 +568,7 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
 	struct tipc_link *l_ptr;
 	struct tipc_link *temp_l_ptr;
 
-	pr_info("TIPC: Disabling bearer <%s>\n", b_ptr->name);
+	pr_info("Disabling bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
 	b_ptr->media->disable_bearer(b_ptr);
@@ -590,7 +590,7 @@ int tipc_disable_bearer(const char *name)
 	write_lock_bh(&tipc_net_lock);
 	b_ptr = tipc_bearer_find(name);
 	if (b_ptr == NULL) {
-		pr_warn("TIPC: Attempt to disable unknown bearer <%s>\n", name);
+		pr_warn("Attempt to disable unknown bearer <%s>\n", name);
 		res = -EINVAL;
 	} else {
 		bearer_disable(b_ptr);
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 7cbff85..a056a38 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -437,7 +437,7 @@ static void cfg_named_msg_event(void *userdata,
 	if ((size < sizeof(*req_hdr)) ||
 	    (size != TCM_ALIGN(ntohl(req_hdr->tcm_len))) ||
 	    (ntohs(req_hdr->tcm_flags) != TCM_F_REQUEST)) {
-		pr_warn("TIPC: Invalid configuration message discarded\n");
+		pr_warn("Invalid configuration message discarded\n");
 		return;
 	}
 
@@ -483,7 +483,7 @@ int tipc_cfg_init(void)
 	return 0;
 
 failed:
-	pr_err("TIPC: Unable to create configuration service\n");
+	pr_err("Unable to create configuration service\n");
 	return res;
 }
 
@@ -499,7 +499,7 @@ void tipc_cfg_reinit(void)
 	seq.lower = seq.upper = tipc_own_addr;
 	res = tipc_publish(config_port_ref, TIPC_ZONE_SCOPE, &seq);
 	if (res)
-		pr_err("TIPC: Unable to reinitialize configuration service\n");
+		pr_err("Unable to reinitialize configuration service\n");
 }
 
 void tipc_cfg_stop(void)
diff --git a/net/tipc/core.c b/net/tipc/core.c
index a6deab4..6586eac 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -34,14 +34,13 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/module.h>
-
 #include "core.h"
 #include "ref.h"
 #include "name_table.h"
 #include "subscr.h"
 #include "config.h"
 
+#include <linux/module.h>
 
 #ifndef CONFIG_TIPC_PORTS
 #define CONFIG_TIPC_PORTS 8191
@@ -157,7 +156,7 @@ static int __init tipc_init(void)
 {
 	int res;
 
-	pr_info("TIPC: Activated (version " TIPC_MOD_VER ")\n");
+	pr_info("Activated (version " TIPC_MOD_VER ")\n");
 
 	tipc_own_addr = 0;
 	tipc_remote_management = 1;
@@ -168,9 +167,9 @@ static int __init tipc_init(void)
 
 	res = tipc_core_start();
 	if (res)
-		pr_err("TIPC: Unable to start in single node mode\n");
+		pr_err("Unable to start in single node mode\n");
 	else
-		pr_info("TIPC: Started in single node mode\n");
+		pr_info("Started in single node mode\n");
 	return res;
 }
 
@@ -178,7 +177,7 @@ static void __exit tipc_exit(void)
 {
 	tipc_core_stop_net();
 	tipc_core_stop();
-	pr_info("TIPC: Deactivated\n");
+	pr_info("Deactivated\n");
 }
 
 module_init(tipc_init);
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 253e53a..fd42e10 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -37,6 +37,8 @@
 #ifndef _TIPC_CORE_H
 #define _TIPC_CORE_H
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/tipc.h>
 #include <linux/tipc_config.h>
 #include <linux/types.h>
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index f385fde..38059e5 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -104,7 +104,7 @@ static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 	tipc_addr_string_fill(node_addr_str, node_addr);
 	tipc_media_addr_printf(media_addr_str, sizeof(media_addr_str),
 			       media_addr);
-	pr_warn("TIPC: Duplicate %s using %s seen on <%s>\n",
+	pr_warn("Duplicate %s using %s seen on <%s>\n",
 		node_addr_str, media_addr_str, b_ptr->name);
 }
 
diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index 061e7a6..7a52d39 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -57,14 +57,14 @@ unsigned int tipc_k_signal(Handler routine, unsigned long argument)
 	struct queue_item *item;
 
 	if (!handler_enabled) {
-		pr_err("TIPC: Signal request ignored by handler\n");
+		pr_err("Signal request ignored by handler\n");
 		return -ENOPROTOOPT;
 	}
 
 	spin_lock_bh(&qitem_lock);
 	item = kmem_cache_alloc(tipc_queue_item_cache, GFP_ATOMIC);
 	if (!item) {
-		pr_err("TIPC: Signal queue out of memory\n");
+		pr_err("Signal queue out of memory\n");
 		spin_unlock_bh(&qitem_lock);
 		return -ENOMEM;
 	}
diff --git a/net/tipc/link.c b/net/tipc/link.c
index dab3503..1c1e615 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -44,9 +44,9 @@
 /*
  * Error message prefixes
  */
-static const char *link_co_err = "TIPC: Link changeover error, ";
-static const char *link_rst_msg = "TIPC: Resetting link ";
-static const char *link_unk_evt = "TIPC: Unknown link event ";
+static const char *link_co_err = "Link changeover error, ";
+static const char *link_rst_msg = "Resetting link ";
+static const char *link_unk_evt = "Unknown link event ";
 
 /*
  * Out-of-range value for link session numbers
@@ -306,21 +306,20 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 
 	if (n_ptr->link_cnt >= 2) {
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
-		pr_err("TIPC: Attempt to establish third link to %s\n",
-		       addr_string);
+		pr_err("Attempt to establish third link to %s\n", addr_string);
 		return NULL;
 	}
 
 	if (n_ptr->links[b_ptr->identity]) {
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
-		pr_err("TIPC: Attempt to establish second link on <%s> to %s\n",
-		    b_ptr->name, addr_string);
+		pr_err("Attempt to establish second link on <%s> to %s\n",
+		       b_ptr->name, addr_string);
 		return NULL;
 	}
 
 	l_ptr = kzalloc(sizeof(*l_ptr), GFP_ATOMIC);
 	if (!l_ptr) {
-		pr_warn("TIPC: Link creation failed, no memory\n");
+		pr_warn("Link creation failed, no memory\n");
 		return NULL;
 	}
 
@@ -378,7 +377,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 void tipc_link_delete(struct tipc_link *l_ptr)
 {
 	if (!l_ptr) {
-		pr_err("TIPC: Attempt to delete non-existent link\n");
+		pr_err("Attempt to delete non-existent link\n");
 		return;
 	}
 
@@ -762,7 +761,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 		}
 		break;
 	default:
-		pr_err("TIPC: Unknown link state %u/%u\n", l_ptr->state, event);
+		pr_err("Unknown link state %u/%u\n", l_ptr->state, event);
 	}
 }
 
@@ -1417,7 +1416,7 @@ static void link_reset_all(unsigned long addr)
 
 	tipc_node_lock(n_ptr);
 
-	pr_warn("TIPC: Resetting all links to %s\n",
+	pr_warn("Resetting all links to %s\n",
 		tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	for (i = 0; i < MAX_BEARERS; i++) {
@@ -1436,7 +1435,7 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 {
 	struct tipc_msg *msg = buf_msg(buf);
 
-	pr_warn("TIPC: Retransmission failure on link <%s>\n", l_ptr->name);
+	pr_warn("Retransmission failure on link <%s>\n", l_ptr->name);
 
 	if (l_ptr->addr) {
 		/* Handle failure on standard link */
@@ -1448,21 +1447,23 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 		struct tipc_node *n_ptr;
 		char addr_string[16];
 
-		pr_info("TIPC: Msg seq number: %u,  ", msg_seqno(msg));
-		pr_info("TIPC: Outstanding acks: %lu\n",
+		pr_info("Msg seq number: %u,  ", msg_seqno(msg));
+		pr_cont("Outstanding acks: %lu\n",
 			(unsigned long) TIPC_SKB_CB(buf)->handle);
 
 		n_ptr = tipc_bclink_retransmit_to();
 		tipc_node_lock(n_ptr);
 
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
-		pr_info("TIPC: Broadcast link info for %s\n", addr_string);
-		pr_info("TIPC: Supportable: %d,  ", n_ptr->bclink.supportable);
-		pr_info("TIPC: Supported: %d,  ", n_ptr->bclink.supported);
-		pr_info("TIPC: Acked: %u\n", n_ptr->bclink.acked);
-		pr_info("TIPC: Last in: %u,  ", n_ptr->bclink.last_in);
-		pr_info("TIPC: Oos state: %u,  ", n_ptr->bclink.oos_state);
-		pr_info("TIPC: Last sent: %u\n", n_ptr->bclink.last_sent);
+		pr_info("Broadcast link info for %s\n", addr_string);
+		pr_info("Supportable: %d,  Supported: %d,  Acked: %u\n",
+			n_ptr->bclink.supportable,
+			n_ptr->bclink.supported,
+			n_ptr->bclink.acked);
+		pr_info("Last in: %u,  Oos state: %u,  Last sent: %u\n",
+			n_ptr->bclink.last_in,
+			n_ptr->bclink.oos_state,
+			n_ptr->bclink.last_sent);
 
 		tipc_k_signal((Handler)link_reset_all, (unsigned long)n_ptr->addr);
 
@@ -1487,8 +1488,8 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 			l_ptr->retransm_queue_head = msg_seqno(msg);
 			l_ptr->retransm_queue_size = retransmits;
 		} else {
-			pr_err("TIPC: Unexpected retransmit on link %s (qsize=%d)\n",
-			    l_ptr->name, l_ptr->retransm_queue_size);
+			pr_err("Unexpected retransmit on link %s (qsize=%d)\n",
+			       l_ptr->name, l_ptr->retransm_queue_size);
 		}
 		return;
 	} else {
@@ -2304,8 +2305,8 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 	if (!dest_link)
 		goto exit;
 	if (dest_link == *l_ptr) {
-		pr_err("TIPC: Unexpected changeover message on link <%s>\n",
-		    (*l_ptr)->name);
+		pr_err("Unexpected changeover message on link <%s>\n",
+		       (*l_ptr)->name);
 		goto exit;
 	}
 	*l_ptr = dest_link;
@@ -2372,7 +2373,7 @@ void tipc_link_recv_bundle(struct sk_buff *buf)
 	while (msgcount--) {
 		obuf = buf_extract(buf, pos);
 		if (obuf == NULL) {
-			pr_warn("TIPC: Link unable to unbundle message(s)\n");
+			pr_warn("Link unable to unbundle message(s)\n");
 			break;
 		}
 		pos += align(msg_size(buf_msg(obuf)));
@@ -2543,7 +2544,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 			set_fragm_size(pbuf, fragm_sz);
 			set_expected_frags(pbuf, exp_fragm_cnt - 1);
 		} else {
-			pr_debug("TIPC: Link unable to reassemble fragmented message\n");
+			pr_debug("Link unable to reassemble fragmented message\n");
 			kfree_skb(fbuf);
 			return -1;
 		}
@@ -3010,7 +3011,7 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 
 static void link_print(struct tipc_link *l_ptr, const char *str)
 {
-	pr_info("TIPC: %s Link %x<%s>:", str, l_ptr->addr, l_ptr->b_ptr->name);
+	pr_info("%s Link %x<%s>:", str, l_ptr->addr, l_ptr->b_ptr->name);
 
 	if (link_working_unknown(l_ptr))
 		pr_cont(":WU\n");
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index cdd614e..55d3928 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -161,7 +161,7 @@ void tipc_named_publish(struct publication *publ)
 
 	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
 	if (!buf) {
-		pr_warn("TIPC: Publication distribution failure\n");
+		pr_warn("Publication distribution failure\n");
 		return;
 	}
 
@@ -186,7 +186,7 @@ void tipc_named_withdraw(struct publication *publ)
 
 	buf = named_prepare_buf(WITHDRAWAL, ITEM_SIZE, 0);
 	if (!buf) {
-		pr_warn("TIPC: Withdrawal distribution failure\n");
+		pr_warn("Withdrawal distribution failure\n");
 		return;
 	}
 
@@ -213,7 +213,7 @@ static void named_distribute(struct list_head *message_list, u32 node,
 			rest -= left;
 			buf = named_prepare_buf(PUBLICATION, left, node);
 			if (!buf) {
-				pr_warn("TIPC: Bulk publication failure\n");
+				pr_warn("Bulk publication failure\n");
 				return;
 			}
 			item = (struct distr_item *)msg_data(buf_msg(buf));
@@ -283,7 +283,7 @@ static void named_purge_publ(struct publication *publ)
 	write_unlock_bh(&tipc_nametbl_lock);
 
 	if (p != publ) {
-		pr_err("TIPC: Unable to remove publication from failed node\n"
+		pr_err("Unable to remove publication from failed node\n"
 		       " (type=%u, lower=%u, node=0x%x, ref=%u, key=%u)\n",
 		       publ->type, publ->lower, publ->node, publ->ref,
 		       publ->key);
@@ -330,14 +330,14 @@ void tipc_named_recv(struct sk_buff *buf)
 				tipc_nodesub_unsubscribe(&publ->subscr);
 				kfree(publ);
 			} else {
-				pr_err("TIPC: Unable to remove publication by node 0x%x\n"
+				pr_err("Unable to remove publication by node 0x%x\n"
 				       " (type=%u, lower=%u, ref=%u, key=%u)\n",
 				       msg_orignode(msg), ntohl(item->type),
 				       ntohl(item->lower), ntohl(item->ref),
 				       ntohl(item->key));
 			}
 		} else {
-			pr_warn("TIPC: Unrecognized name table message received\n");
+			pr_warn("Unrecognized name table message received\n");
 		}
 		item++;
 	}
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 0b7eaf1..360c478 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -126,7 +126,7 @@ static struct publication *publ_create(u32 type, u32 lower, u32 upper,
 {
 	struct publication *publ = kzalloc(sizeof(*publ), GFP_ATOMIC);
 	if (publ == NULL) {
-		pr_warn("TIPC: Publication creation failure, no memory\n");
+		pr_warn("Publication creation failure, no memory\n");
 		return NULL;
 	}
 
@@ -163,7 +163,7 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
 	struct sub_seq *sseq = tipc_subseq_alloc(1);
 
 	if (!nseq || !sseq) {
-		pr_warn("TIPC: Name sequence creation failed, no memory\n");
+		pr_warn("Name sequence creation failed, no memory\n");
 		kfree(nseq);
 		kfree(sseq);
 		return NULL;
@@ -263,7 +263,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 
 		/* Lower end overlaps existing entry => need an exact match */
 		if ((sseq->lower != lower) || (sseq->upper != upper)) {
-			pr_warn("TIPC: Cannot publish {%u,%u,%u}, overlap error\n",
+			pr_warn("Cannot publish {%u,%u,%u}, overlap error\n",
 				type, lower, upper);
 			return NULL;
 		}
@@ -286,7 +286,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		/* Fail if upper end overlaps into an existing entry */
 		if ((inspos < nseq->first_free) &&
 		    (upper >= nseq->sseqs[inspos].lower)) {
-			pr_warn("TIPC: Cannot publish {%u,%u,%u}, overlap error\n",
+			pr_warn("Cannot publish {%u,%u,%u}, overlap error\n",
 				type, lower, upper);
 			return NULL;
 		}
@@ -296,7 +296,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 			struct sub_seq *sseqs = tipc_subseq_alloc(nseq->alloc * 2);
 
 			if (!sseqs) {
-				pr_warn("TIPC: Cannot publish {%u,%u,%u}, no memory\n",
+				pr_warn("Cannot publish {%u,%u,%u}, no memory\n",
 					type, lower, upper);
 				return NULL;
 			}
@@ -309,7 +309,7 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 
 		info = kzalloc(sizeof(*info), GFP_ATOMIC);
 		if (!info) {
-			pr_warn("TIPC: Cannot publish {%u,%u,%u}, no memory\n",
+			pr_warn("Cannot publish {%u,%u,%u}, no memory\n",
 				type, lower, upper);
 			return NULL;
 		}
@@ -492,7 +492,7 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 
 	if ((scope < TIPC_ZONE_SCOPE) || (scope > TIPC_NODE_SCOPE) ||
 	    (lower > upper)) {
-		pr_debug("TIPC: Failed to publish illegal {%u,%u,%u} with scope %u\n",
+		pr_debug("Failed to publish illegal {%u,%u,%u} with scope %u\n",
 			 type, lower, upper, scope);
 		return NULL;
 	}
@@ -668,7 +668,7 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	struct publication *publ;
 
 	if (table.local_publ_count >= tipc_max_publications) {
-		pr_warn("TIPC: Publication failed, local publication limit reached (%u)\n",
+		pr_warn("Publication failed, local publication limit reached (%u)\n",
 			tipc_max_publications);
 		return NULL;
 	}
@@ -702,7 +702,7 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 		return 1;
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
-	pr_err("TIPC: Unable to remove local publication\n"
+	pr_err("Unable to remove local publication\n"
 	       "(type=%u, lower=%u, ref=%u, key=%u)\n",
 	       type, lower, ref, key);
 	return 0;
@@ -725,7 +725,7 @@ void tipc_nametbl_subscribe(struct tipc_subscription *s)
 		tipc_nameseq_subscribe(seq, s);
 		spin_unlock_bh(&seq->lock);
 	} else {
-		pr_warn("TIPC: Failed to create subscription for {%u,%u,%u}\n",
+		pr_warn("Failed to create subscription for {%u,%u,%u}\n",
 			s->seq.type, s->seq.lower, s->seq.upper);
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
@@ -956,7 +956,7 @@ void tipc_nametbl_stop(void)
 	for (i = 0; i < tipc_nametbl_size; i++) {
 		if (hlist_empty(&table.types[i]))
 			continue;
-		pr_err("TIPC: nametbl_stop(): orphaned hash chain detected\n");
+		pr_err("nametbl_stop(): orphaned hash chain detected\n");
 		break;
 	}
 	kfree(table.types);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 38a34b9..5b5cea2 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -184,8 +184,8 @@ int tipc_net_start(u32 addr)
 
 	tipc_cfg_reinit();
 
-	pr_info("TIPC: Started in network mode\n");
-	pr_info("TIPC: Own node address %s, network identity %u\n",
+	pr_info("Started in network mode\n");
+	pr_info("Own node address %s, network identity %u\n",
 		tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
 	return 0;
 }
@@ -202,5 +202,5 @@ void tipc_net_stop(void)
 	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
 		tipc_node_delete(node);
 	write_unlock_bh(&tipc_net_lock);
-	pr_info("TIPC: Left network mode\n");
+	pr_info("Left network mode\n");
 }
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index f8ca12d..47a839d 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -90,7 +90,7 @@ int tipc_netlink_start(void)
 	res = genl_register_family_with_ops(&tipc_genl_family,
 		&tipc_genl_ops, 1);
 	if (res) {
-		pr_err("TIPC: Failed to register netlink interface\n");
+		pr_err("Failed to register netlink interface\n");
 		return res;
 	}
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index e03fc45..d21db20 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -105,7 +105,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 	n_ptr = kzalloc(sizeof(*n_ptr), GFP_ATOMIC);
 	if (!n_ptr) {
 		spin_unlock_bh(&node_create_lock);
-		pr_warn("TIPC: Node creation failed, no memory\n");
+		pr_warn("Node creation failed, no memory\n");
 		return NULL;
 	}
 
@@ -151,7 +151,7 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 
 	n_ptr->working_links++;
 
-	pr_info("TIPC: Established link <%s> on network plane %c\n",
+	pr_info("Established link <%s> on network plane %c\n",
 		l_ptr->name, l_ptr->b_ptr->net_plane);
 
 	if (!active[0]) {
@@ -160,7 +160,7 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		return;
 	}
 	if (l_ptr->priority < active[0]->priority) {
-		pr_info("TIPC: New link <%s> becomes standby\n", l_ptr->name);
+		pr_info("New link <%s> becomes standby\n", l_ptr->name);
 		return;
 	}
 	tipc_link_send_duplicate(active[0], l_ptr);
@@ -168,10 +168,9 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		active[0] = l_ptr;
 		return;
 	}
-	pr_info("TIPC: Old link <%s> becomes standby\n", active[0]->name);
+	pr_info("Old link <%s> becomes standby\n", active[0]->name);
 	if (active[1] != active[0])
-		pr_info("TIPC: Old link <%s> becomes standby\n",
-			active[1]->name);
+		pr_info("Old link <%s> becomes standby\n", active[1]->name);
 	active[0] = active[1] = l_ptr;
 }
 
@@ -212,11 +211,11 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	n_ptr->working_links--;
 
 	if (!tipc_link_is_active(l_ptr)) {
-		pr_info("TIPC: Lost standby link <%s> on network plane %c\n",
+		pr_info("Lost standby link <%s> on network plane %c\n",
 			l_ptr->name, l_ptr->b_ptr->net_plane);
 		return;
 	}
-	pr_info("TIPC: Lost link <%s> on network plane %c\n",
+	pr_info("Lost link <%s> on network plane %c\n",
 		l_ptr->name, l_ptr->b_ptr->net_plane);
 
 	active = &n_ptr->active_links[0];
@@ -291,7 +290,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	char addr_string[16];
 	u32 i;
 
-	pr_info("TIPC: Lost contact with %s\n",
+	pr_info("Lost contact with %s\n",
 		tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	/* Flush broadcast link info associated with lost node */
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index 2256281..5e34b01 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -51,7 +51,7 @@ void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
 
 	node_sub->node = tipc_node_find(addr);
 	if (!node_sub->node) {
-		pr_warn("TIPC: Node subscription rejected, unknown node 0x%x\n",
+		pr_warn("Node subscription rejected, unknown node 0x%x\n",
 			addr);
 		return;
 	}
diff --git a/net/tipc/port.c b/net/tipc/port.c
index cee4d24..07c42fb 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -191,7 +191,7 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct tipc_port_list *dp)
 			struct sk_buff *b = skb_clone(buf, GFP_ATOMIC);
 
 			if (b == NULL) {
-				pr_warn("TIPC: Unable to deliver multicast message(s)\n");
+				pr_warn("Unable to deliver multicast message(s)\n");
 				goto exit;
 			}
 			if ((index == 0) && (cnt != 0))
@@ -221,12 +221,12 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 
 	p_ptr = kzalloc(sizeof(*p_ptr), GFP_ATOMIC);
 	if (!p_ptr) {
-		pr_warn("TIPC: Port creation failed, no memory\n");
+		pr_warn("Port creation failed, no memory\n");
 		return NULL;
 	}
 	ref = tipc_ref_acquire(p_ptr, &p_ptr->lock);
 	if (!ref) {
-		pr_warn("TIPC: Port creation failed, ref. table exhausted\n");
+		pr_warn("Port creation failed, ref. table exhausted\n");
 		kfree(p_ptr);
 		return NULL;
 	}
@@ -912,7 +912,7 @@ int tipc_createport(void *usr_handle,
 
 	up_ptr = kmalloc(sizeof(*up_ptr), GFP_ATOMIC);
 	if (!up_ptr) {
-		pr_warn("TIPC: Port creation failed, no memory\n");
+		pr_warn("Port creation failed, no memory\n");
 		return -ENOMEM;
 	}
 	p_ptr = tipc_createport_raw(NULL, port_dispatcher, port_wakeup,
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 7435871..2a2a938 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -153,11 +153,11 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 	struct reference *entry = NULL;
 
 	if (!object) {
-		pr_err("TIPC: Attempt to acquire ref. to non-existent obj\n");
+		pr_err("Attempt to acquire ref. to non-existent obj\n");
 		return 0;
 	}
 	if (!tipc_ref_table.entries) {
-		pr_err("TIPC: Ref. table not found in acquisition attempt\n");
+		pr_err("Ref. table not found in acquisition attempt\n");
 		return 0;
 	}
 
@@ -211,7 +211,7 @@ void tipc_ref_discard(u32 ref)
 	u32 index_mask;
 
 	if (!tipc_ref_table.entries) {
-		pr_err("TIPC: Ref. table not found during discard attempt\n");
+		pr_err("Ref. table not found during discard attempt\n");
 		return;
 	}
 
@@ -222,11 +222,11 @@ void tipc_ref_discard(u32 ref)
 	write_lock_bh(&ref_table_lock);
 
 	if (!entry->object) {
-		pr_err("TIPC: Attempt to discard ref. to non-existent obj\n");
+		pr_err("Attempt to discard ref. to non-existent obj\n");
 		goto exit;
 	}
 	if (entry->ref != ref) {
-		pr_err("TIPC: Attempt to discard non-existent reference\n");
+		pr_err("Attempt to discard non-existent reference\n");
 		goto exit;
 	}
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index fefec9c..09dc5b9 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -34,12 +34,12 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include <linux/export.h>
-#include <net/sock.h>
-
 #include "core.h"
 #include "port.h"
 
+#include <linux/export.h>
+#include <net/sock.h>
+
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
 
@@ -1787,13 +1787,13 @@ int tipc_socket_init(void)
 
 	res = proto_register(&tipc_proto, 1);
 	if (res) {
-		pr_err("TIPC: Failed to register TIPC protocol type\n");
+		pr_err("Failed to register TIPC protocol type\n");
 		goto out;
 	}
 
 	res = sock_register(&tipc_family_ops);
 	if (res) {
-		pr_err("TIPC: Failed to register TIPC socket type\n");
+		pr_err("Failed to register TIPC socket type\n");
 		proto_unregister(&tipc_proto);
 		goto out;
 	}
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 18703a5..5ed5965 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -305,7 +305,7 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 
 	/* Refuse subscription if global limit exceeded */
 	if (atomic_read(&topsrv.subscription_count) >= tipc_max_subscriptions) {
-		pr_warn("TIPC: Subscription rejected, limit reached (%u)\n",
+		pr_warn("Subscription rejected, limit reached (%u)\n",
 			tipc_max_subscriptions);
 		subscr_terminate(subscriber);
 		return NULL;
@@ -314,7 +314,7 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	/* Allocate subscription object */
 	sub = kmalloc(sizeof(*sub), GFP_ATOMIC);
 	if (!sub) {
-		pr_warn("TIPC: Subscription rejected, no memory\n");
+		pr_warn("Subscription rejected, no memory\n");
 		subscr_terminate(subscriber);
 		return NULL;
 	}
@@ -328,7 +328,7 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	if ((!(sub->filter & TIPC_SUB_PORTS) ==
 	     !(sub->filter & TIPC_SUB_SERVICE)) ||
 	    (sub->seq.lower > sub->seq.upper)) {
-		pr_warn("TIPC: Subscription rejected, illegal request\n");
+		pr_warn("Subscription rejected, illegal request\n");
 		kfree(sub);
 		subscr_terminate(subscriber);
 		return NULL;
@@ -440,7 +440,7 @@ static void subscr_named_msg_event(void *usr_handle,
 	/* Create subscriber object */
 	subscriber = kzalloc(sizeof(struct tipc_subscriber), GFP_ATOMIC);
 	if (subscriber == NULL) {
-		pr_warn("TIPC: Subscriber rejected, no memory\n");
+		pr_warn("Subscriber rejected, no memory\n");
 		return;
 	}
 	INIT_LIST_HEAD(&subscriber->subscription_list);
@@ -458,7 +458,7 @@ static void subscr_named_msg_event(void *usr_handle,
 			NULL,
 			&subscriber->port_ref);
 	if (subscriber->port_ref == 0) {
-		pr_warn("TIPC: Subscriber rejected, unable to create port\n");
+		pr_warn("Subscriber rejected, unable to create port\n");
 		kfree(subscriber);
 		return;
 	}
@@ -517,7 +517,7 @@ int tipc_subscr_start(void)
 	return 0;
 
 failed:
-	pr_err("TIPC: Failed to create subscription service\n");
+	pr_err("Failed to create subscription service\n");
 	return res;
 }
 
