From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/7] net: correct comment on where to place transmit time stamp hook.
Date: Sun, 19 Jun 2011 15:31:39 +0200
Message-ID: <a3029c0dc2a700edc8f37b8831979c247486838c.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55555 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab1FSNbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 09:31:49 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so477619fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 06:31:49 -0700 (PDT)
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308489767.git.richard.cochran@omicron.at>
References: <cover.1308489767.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comment for the skb_tx_timestamp() function suggests calling it just
after a buffer is released to the hardware for transmission. However,
for drivers that free the buffer in an ISR, this produces a race between
the time stamp code and the ISR. This commit changes the comment to advise
placing the call just before handing the buffer over to the hardware.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/skbuff.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c0a4f3a..3e54337 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2028,8 +2028,7 @@ static inline void sw_tx_timestamp(struct sk_buff *skb)
  * skb_tx_timestamp() - Driver hook for transmit timestamping
  *
  * Ethernet MAC Drivers should call this function in their hard_xmit()
- * function as soon as possible after giving the sk_buff to the MAC
- * hardware, but before freeing the sk_buff.
+ * function immediately before giving the sk_buff to the MAC hardware.
  *
  * @skb: A socket buffer.
  */
-- 
1.7.0.4

