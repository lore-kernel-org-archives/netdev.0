From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 9/14] [TIPC] Name publication events now delivered in chronological order
Date: Fri, 13 Oct 2006 13:37:50 +0200
Message-ID: <1160739475953-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:47264 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751396AbWJMLiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This patch tivially re-orders the entries in TIPC's list of local
publications so that applications will receive publication events
in the order they were published.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/name_distr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index f0b063b..03bd659 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -122,7 +122,7 @@ void tipc_named_publish(struct publicati
 	struct sk_buff *buf;
 	struct distr_item *item;
 
-	list_add(&publ->local_list, &publ_root);
+	list_add_tail(&publ->local_list, &publ_root);
 	publ_cnt++;
 
 	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
-- 
1.4.1

