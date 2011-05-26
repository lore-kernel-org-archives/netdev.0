From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH] sctp compilation failed due to lack of
 sctp_local_addr_free
Date: Thu, 26 May 2011 19:28:43 +0300
Message-ID: <1306427323.7510.2.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Jacek Luczak" <difrost.kernel@gmail.com>
To: "david Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3737 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756729Ab1EZQ2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 12:28:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
1.7.2.2




