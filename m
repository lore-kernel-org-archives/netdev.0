From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] netlabel: Fix a problem when dumping the default IPv6 static
	labels
Date: Wed, 25 Jun 2008 16:29:13 -0400
Message-ID: <20080625202913.19613.5413.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:36944 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751144AbYFYU3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 16:29:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a missing "!" in a conditional statement which is causing entries to
be skipped when dumping the default IPv6 static label entries.  This can be
demonstrated by running the following:

 # netlabelctl unlbl add default address:::1 \
                                 label:system_u:object_r:unlabeled_t:s0
 # netlabelctl -p unlbl list

... you will notice that the entry for the IPv6 localhost address is not
displayed but does exist (works correctly, causes collisions when attempting
to add duplicate entries, etc.).

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/netlabel/netlabel_unlabeled.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 0099da5..52b2611 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1534,7 +1534,7 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 		}
 	}
 	list_for_each_entry_rcu(addr6, &iface->addr6_list, list) {
-		if (addr6->valid || iter_addr6++ < skip_addr6)
+		if (!addr6->valid || iter_addr6++ < skip_addr6)
 			continue;
 		if (netlbl_unlabel_staticlist_gen(NLBL_UNLABEL_C_STATICLISTDEF,
 					   iface,

