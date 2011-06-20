From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 01/11] net: export the receive time stamping hook for non-NAPI drivers
Date: Mon, 20 Jun 2011 09:51:23 +0200
Message-ID: <cf1d6f373d83c3a1cbaf53a06ee331d5d950f25b.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40854 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601Ab1FTHva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:51:30 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so760782fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:51:29 -0700 (PDT)
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet MAC drivers based on phylib (but not using NAPI) can
enable hardware time stamping in phy devices by calling netif_rx()
conditionally based on a call to skb_defer_rx_timestamp().

This commit exports that function so that drivers calling it may
be compiled as modules.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 net/core/timestamping.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 3b00a6b..98a5264 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -122,6 +122,7 @@ bool skb_defer_rx_timestamp(struct sk_buff *skb)
 
 	return false;
 }
+EXPORT_SYMBOL_GPL(skb_defer_rx_timestamp);
 
 void __init skb_timestamping_init(void)
 {
-- 
1.7.0.4

