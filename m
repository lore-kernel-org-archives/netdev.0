From: Timo Juhani Lindfors <timo.lindfors@iki.fi>
Subject: [PATCH] ip: use checksum options of first fragment also for subsequent fragments
Date: Tue, 14 Dec 2010 09:51:33 +0200
Message-ID: <1292313093-11973-1-git-send-email-timo.lindfors@iki.fi>
Cc: Timo Juhani Lindfors <timo.lindfors@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.netsonic.fi ([194.29.192.26]:48193 "EHLO smtp.netsonic.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754989Ab0LNKhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 05:37:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reference: https://bugzilla.kernel.org/show_bug.cgi?id=24832
Signed-off-by: Timo Juhani Lindfors <timo.lindfors@iki.fi>
---
 net/ipv4/ip_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 439d2a3..c0743ed 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1167,7 +1167,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
 			/*
 			 *	Fill in the control structures
 			 */
-			skb->ip_summed = CHECKSUM_NONE;
+			skb->ip_summed = skb_prev->ip_summed;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
 
-- 
1.7.2.3

