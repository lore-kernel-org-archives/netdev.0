From: David Miller <davem@davemloft.net>
Subject: [PATCH 35/42] l2tp: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:13 -0700 (PDT)
Message-ID: <20110417.173413.52195546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754143Ab1DRAes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DA14024C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'ret' is set but unused in l2tp_nl_register_ops().

This was obviously meant to maintain error codes which are
returned to the caller, make it so.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_netlink.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 4c1e540..93a41a0 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -795,11 +795,12 @@ int l2tp_nl_register_ops(enum l2tp_pwtype pw_type, const struct l2tp_nl_cmd_ops
 		goto out;
 
 	l2tp_nl_cmd_ops[pw_type] = ops;
+	ret = 0;
 
 out:
 	genl_unlock();
 err:
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(l2tp_nl_register_ops);
 
-- 
1.7.4.3

