From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 1/14] [TIPC] Add missing unlock in port timeout code.
Date: Fri, 13 Oct 2006 13:37:42 +0200
Message-ID: <11607394751193-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:39072 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751375AbWJMLh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:37:59 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/port.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index b9c8c6b..c1a1a76 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -505,8 +505,13 @@ static void port_timeout(unsigned long r
 	struct port *p_ptr = tipc_port_lock(ref);
 	struct sk_buff *buf = NULL;
 
-	if (!p_ptr || !p_ptr->publ.connected)
+	if (!p_ptr)
+		return;
+
+	if (!p_ptr->publ.connected) {
+		tipc_port_unlock(p_ptr);
 		return;
+	}
 
 	/* Last probe answered ? */
 	if (p_ptr->probing_state == PROBING) {
-- 
1.4.1

