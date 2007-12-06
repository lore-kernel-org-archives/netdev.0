From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 6/7] [CCID3]: The receiver of a half-connection does not set window counter values
Date: Thu,  6 Dec 2007 19:02:53 -0200
Message-ID: <1196974974-31531-7-git-send-email-acme@redhat.com>
References: <1196974974-31531-1-git-send-email-acme@redhat.com>
 <1196974974-31531-2-git-send-email-acme@redhat.com>
 <1196974974-31531-3-git-send-email-acme@redhat.com>
 <1196974974-31531-4-git-send-email-acme@redhat.com>
 <1196974974-31531-5-git-send-email-acme@redhat.com>
 <1196974974-31531-6-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:55864 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbXLFVDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 16:03:55 -0500
Received: by an-out-0708.google.com with SMTP id d31so97980and
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2007 13:03:54 -0800 (PST)
In-Reply-To: <1196974974-31531-6-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Only the sender sets window counters [RFC 4342, sections 5 and 8.1].

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index c95dca8..5ff5aab 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -733,7 +733,6 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 		return 0;
 
 	hcrx = ccid3_hc_rx_sk(sk);
-	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_ccval_last_counter;
 
 	if (dccp_packet_without_ack(skb))
 		return 0;
-- 
1.5.3.4

