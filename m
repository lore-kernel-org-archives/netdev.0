From: Chang Xiangzhong <changxiangzhong@gmail.com>
Subject: [PATCH 1/1] net: sctp: bug fixing when sctp path recovers
Date: Wed, 13 Nov 2013 02:34:46 +0100
Message-ID: <1384306486-31345-1-git-send-email-changxiangzhong@gmail.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dreibh@simula.no,
	Chang Xiangzhong <changxiangzhong@gmail.com>
To: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:63965 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269Ab3KMBfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 20:35:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Look for the __two__ most recently used path/transport and set to active_path
and retran_path respectively

Signed-off-by: changxiangzhong@gmail.com
---
 net/sctp/associola.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index ab67efc..070011a 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -913,11 +913,15 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
 		if (!first || t->last_time_heard > first->last_time_heard) {
 			second = first;
 			first = t;
+			continue;
 		}
 		if (!second || t->last_time_heard > second->last_time_heard)
 			second = t;
 	}
 
+	if (!second)
+		second = first;
+
 	/* RFC 2960 6.4 Multi-Homed SCTP Endpoints
 	 *
 	 * By default, an endpoint should always transmit to the
-- 
1.7.9.5
