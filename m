From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] sctp: fixed missing fixup of sctp_local_addr_free
Date: Fri, 27 May 2011 13:37:00 -0400
Message-ID: <1306517820-4793-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43541 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab1E0Rhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 13:37:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1231f0baa547a541a7481119323b7f964dda4788  Converted sctp to use
kfree_rcu from sctp_local_addr_free but missed this one call point.  Fix it up
accordingly.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Vlad Yasevich <vladislav.yasevich@hp.com>
CC: Sridhar Samudrala <sri@us.ibm.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: linux-sctp@vger.kernel.org
---
 net/sctp/bind_addr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 6338413..83e3011 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -145,7 +145,7 @@ static void sctp_bind_addr_clean(struct sctp_bind_addr *bp)
 	/* Empty the bind address list. */
 	list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
 		list_del_rcu(&addr->list);
-		call_rcu(&addr->rcu, sctp_local_addr_free);
+		kfree_rcu(addr, rcu);
 		SCTP_DBG_OBJCNT_DEC(addr);
 	}
 }
-- 
1.7.5.2

