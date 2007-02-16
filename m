From: Max Krasnyansky <maxk@qualcomm.com>
Subject: [TIPC] Properly mask header fields
Date: Thu, 15 Feb 2007 22:27:33 -0800
Message-ID: <1171607254637-git-send-email-maxk@qualcomm.com>
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from warlock.qualcomm.com ([129.46.50.49]:48753 "EHLO
	warlock.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964793AbXBPHE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 02:04:29 -0500
Received: from numenor.qualcomm.com (numenor.qualcomm.com [129.46.51.58])
	by warlock.qualcomm.com (8.13.6/8.13.6/1.0) with ESMTP id l1G6cs6J019968
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 22:38:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TIPC code is a bit inconsistent in masking out upper bits of various
message fields when packing them into the headers. For the most part
things seem to be ok but we happened to hit a corner case in our labs
when broadcast counter reached certain value (don't remember exact
details) and was messing up status bits in the header. At which point
the link was busted and required a reset to bring it back up.
It's much safer to apply proper mask in the function that does the
actual packing rather than doing it all over the place, and missing a
few ;-).

Signed-off-by: Max Krasnyansky <maxk@qualcomm.com>
---
 net/tipc/msg.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 6699aaf..4e681c8 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -72,7 +72,7 @@ static inline void msg_set_bits(struct tipc_msg *m, u32 w,
 				u32 pos, u32 mask, u32 val)
 {
 	u32 word = msg_word(m,w) & ~(mask << pos);
-	msg_set_word(m, w, (word |= (val << pos)));
+	msg_set_word(m, w, (word |= ((val & mask) << pos)));
 }
 
 /* 
-- 
1.4.4.2

