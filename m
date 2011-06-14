From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/2] batman-adv: compare_eth() should take const pointer
 arguments
Date: Wed, 15 Jun 2011 00:51:42 +0100
Message-ID: <20110614235142.3724.92963.stgit@warthog.procyon.org.uk>
References: <20110614235132.3724.57632.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Howells <dhowells@redhat.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Sven Eckelmann <sven@narfation.org>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303Ab1FNXvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 19:51:51 -0400
In-Reply-To: <20110614235132.3724.57632.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

compare_eth() should take const pointer arguments so that it can be passed
const pointers without the need for a cast, leading to:

net/batman-adv/vis.c: In function 'vis_data_insert_interface':
net/batman-adv/vis.c:146: warning: passing argument 2 of 'compare_eth' discards qualifiers from pointer target type

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Marek Lindner <lindner_marek@yahoo.de>
cc: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
cc: Sven Eckelmann <sven@narfation.org>
cc: b.a.t.m.a.n@lists.open-mesh.org
cc: netdev@vger.kernel.org
---

 net/batman-adv/main.h |    2 +-
 net/batman-adv/vis.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 148b49e..e6fc798 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -172,7 +172,7 @@ static inline void bat_dbg(char type __always_unused,
  *
  * note: can't use compare_ether_addr() as it requires aligned memory
  */
-static inline int compare_eth(void *data1, void *data2)
+static inline int compare_eth(const void *data1, const void *data2)
 {
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index c39f20c..34053ac 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -143,7 +143,7 @@ static void vis_data_insert_interface(const uint8_t *interface,
 	struct hlist_node *pos;
 
 	hlist_for_each_entry(entry, pos, if_list, list) {
-		if (compare_eth(entry->addr, (void *)interface))
+		if (compare_eth(entry->addr, interface))
 			return;
 	}
 

