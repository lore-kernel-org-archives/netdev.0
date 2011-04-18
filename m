From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/42] ax25: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:32:57 -0700 (PDT)
Message-ID: <20110417.173257.59682919.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40545
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753629Ab1DRAdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 558C424C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 's' is set but unused in ax25_protocol_release().
Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ax25/ax25_iface.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ax25/ax25_iface.c b/net/ax25/ax25_iface.c
index 5a0dda8..60b545e 100644
--- a/net/ax25/ax25_iface.c
+++ b/net/ax25/ax25_iface.c
@@ -58,7 +58,7 @@ EXPORT_SYMBOL_GPL(ax25_register_pid);
 
 void ax25_protocol_release(unsigned int pid)
 {
-	struct ax25_protocol *s, *protocol;
+	struct ax25_protocol *protocol;
 
 	write_lock_bh(&protocol_list_lock);
 	protocol = protocol_list;
@@ -72,7 +72,6 @@ void ax25_protocol_release(unsigned int pid)
 
 	while (protocol != NULL && protocol->next != NULL) {
 		if (protocol->next->pid == pid) {
-			s = protocol->next;
 			protocol->next = protocol->next->next;
 			goto out;
 		}
-- 
1.7.4.3

