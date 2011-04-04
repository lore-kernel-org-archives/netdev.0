From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] pppoe: drop PPPOX_ZOMBIEs in pppoe_flush_dev
Date: Mon, 4 Apr 2011 14:33:24 +0200
Message-ID: <20110404123324.GA12662@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-45.dex002.intermedia.net ([64.78.21.137]:18373 "EHLO
	dhost002-45.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288Ab1DDMrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 08:47:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

otherwise we loop forever if a PPPoE socket was set
to PPPOX_ZOMBIE state by a PADT message when the
ethernet device is going down afterwards.

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 drivers/net/pppoe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 78c0e3c..71b1d8f 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -317,7 +317,7 @@ static void pppoe_flush_dev(struct net_device *dev)
 			lock_sock(sk);
 
 			if (po->pppoe_dev == dev &&
-			    sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
+			    sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) {
 				pppox_unbind_sock(sk);
 				sk->sk_state = PPPOX_ZOMBIE;
 				sk->sk_state_change(sk);
-- 
1.7.1

