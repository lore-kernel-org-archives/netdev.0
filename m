From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ixgb: fix TX hangs under heavy load
Date: Tue, 30 Oct 2007 11:21:50 -0700
Message-ID: <20071030182150.25962.48103.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	andy@greyhouse.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56944 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184AbXJ3SZT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 14:25:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A merge error occurred where we merged the wrong block here
in version 1.0.120. The right condition for frags is slightly
different then for the skb, so account for the difference properly
and trim the TSO based size right.

Originally part of a fix reported by IBM to fix TSO hangs on
pSeries hardware.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---

 drivers/net/ixgb/ixgb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index e564335..3021234 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1321,8 +1321,8 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 			/* Workaround for premature desc write-backs
 			 * in TSO mode.  Append 4-byte sentinel desc */
-			if (unlikely(mss && !nr_frags && size == len
-			             && size > 8))
+			if (unlikely(mss && (f == (nr_frags - 1))
+				     && size == len && size > 8))
 				size -= 4;
 
 			buffer_info->length = size;
