From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/4] net: add _skb_dst opaque field
Date: Tue, 02 Jun 2009 17:13:45 +0200
Message-ID: <4A2541A9.1030109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58143 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbZFBPNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 11:13:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct sk_buff uses one union to define dst and rtable fields.

We want to replace direct access to these pointers by accessors.

First patch adds a new "unsigned long _skb_dst;" opaque field
in this union.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index aff494b..d4d7c66 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -325,6 +325,7 @@ struct sk_buff {
 	union {
 		struct  dst_entry	*dst;
 		struct  rtable		*rtable;
+		unsigned long		_skb_dst;
 	};
 #ifdef CONFIG_XFRM
 	struct	sec_path	*sp;
