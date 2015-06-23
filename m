From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: multicast: add a comment to br_port_state_selection about blocking state
Date: Tue, 23 Jun 2015 04:47:44 -0700
Message-ID: <1435060064-32761-1-git-send-email-nikolay@cumulusnetworks.com>
References: <77FF1B4A-1D3A-4F59-A7C7-0ADBB34F8920@cumulusnetworks.com>
Cc: sashok@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, herbert@gondor.apana.org.au,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35504 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445AbbFWLsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 07:48:03 -0400
Received: by pdbci14 with SMTP id ci14so5792361pdb.2
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 04:48:02 -0700 (PDT)
In-Reply-To: <77FF1B4A-1D3A-4F59-A7C7-0ADBB34F8920@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a comment to explain why we're not disabling port's multicast when it
goes in blocking state. Since there's a check in the timer's function which
bypasses the timer if the port's in blocking/disabled state, the timer will
simply expire and stop without sending more queries.

Suggested-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_stp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index e7ab74b405a1..b4b6dab9c285 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -463,6 +463,10 @@ void br_port_state_selection(struct net_bridge *br)
 
 		if (p->state != BR_STATE_BLOCKING)
 			br_multicast_enable_port(p);
+		/* Multicast is not disabled for the port when it goes in
+		 * blocking state because the timers will expire and stop by
+		 * themselves without sending more queries.
+		 */
 		if (p->state == BR_STATE_FORWARDING)
 			++liveports;
 	}
-- 
1.9.1
