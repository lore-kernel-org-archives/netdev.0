From: James Chapman <jchapman@katalix.com>
Subject: [PATCH net-next 2/2] l2tp: fix data packet sequence number handling
Date: Thu, 10 May 2012 10:43:09 +0100
Message-ID: <1336642989-4785-2-git-send-email-jchapman@katalix.com>
References: <1336642989-4785-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:33593 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757900Ab2EJJnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 05:43:13 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id 19012A6212A
	for <netdev@vger.kernel.org>; Thu, 10 May 2012 10:43:10 +0100 (BST)
In-Reply-To: <1336642989-4785-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If enabled, L2TP data packets have sequence numbers which a receiver
can use to drop out of sequence frames or try to reorder them. The
first frame has sequence number 0, but the L2TP code currently expects
it to be 1. This results in the first data frame being handled as out
of sequence.

This one-line patch fixes the problem.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index d1ab3a2..0d6aedc 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1762,7 +1762,7 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 
 		session->session_id = session_id;
 		session->peer_session_id = peer_session_id;
-		session->nr = 1;
+		session->nr = 0;
 
 		sprintf(&session->name[0], "sess %u/%u",
 			tunnel->tunnel_id, session->session_id);
-- 
1.7.0.4
