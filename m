From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2.6.24] ixgb: TX hangs under heavy load
Date: Tue, 30 Oct 2007 08:50:55 -0400
Message-ID: <20071030125055.GA7195@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zenyowu@tw.ibm.com, netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbXJ3MvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 08:51:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Auke,

It has become clear that this patch resolves some tx-lockups on the ixgb
driver.  IBM did some checking and realized this hunk is in your
sourceforge driver, but not anywhere else.  Mind if we add it?

Thanks,

-andy

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---

 ixgb_main.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index d444de5..3ec7a41 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1324,7 +1324,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 			/* Workaround for premature desc write-backs
 			 * in TSO mode.  Append 4-byte sentinel desc */
-			if (unlikely(mss && !nr_frags && size == len
+			if (unlikely(mss && (f == (nr_frags-1)) && size == len
 			             && size > 8))
 				size -= 4;
 
