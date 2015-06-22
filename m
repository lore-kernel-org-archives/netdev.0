From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: multicast: disable port when in blocking state
Date: Mon, 22 Jun 2015 13:12:11 -0700
Message-ID: <1435003931-6418-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: sashok@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, herbert@gondor.apana.org.au,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36210 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbbFVUMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 16:12:36 -0400
Received: by paceq1 with SMTP id eq1so116241430pac.3
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 13:12:36 -0700 (PDT)
In-Reply-To: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently when a port goes in blocking state the multicast is not
disabled. Fix it by disabling a port if its state has transitioned to
blocking, this has effect for both user- and kernel-space stp.

Reported-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
note: this is on top of patch:
"bridge: multicast: start querier timer when running user-space stp"

 net/bridge/br_stp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index e7ab74b405a1..1a73c5595f52 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -463,6 +463,8 @@ void br_port_state_selection(struct net_bridge *br)
 
 		if (p->state != BR_STATE_BLOCKING)
 			br_multicast_enable_port(p);
+		else
+			br_multicast_disable_port(p);
 		if (p->state == BR_STATE_FORWARDING)
 			++liveports;
 	}
-- 
2.4.3
