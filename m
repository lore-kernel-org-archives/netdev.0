From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] pptp: validate sockaddr_len before binding
Date: Mon, 14 Dec 2015 23:45:28 +0100
Message-ID: <1450133128-18845-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:56732 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753453AbbLNWpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 17:45:40 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 7A53921770
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 17:45:39 -0500 (EST)
Received: from z.com (unknown [213.55.184.189])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8CD9DC016F6
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 17:45:38 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Dmitry Vyukov <dvyukov@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ppp/pptp.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index fc69e41d09506e..f9ffdf070ad807 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -419,6 +419,9 @@ static int pptp_bind(struct socket *sock, struct sockaddr *uservaddr,
 	struct pptp_opt *opt = &po->proto.pptp;
 	int error = 0;
 
+	if (sockaddr_len < sizeof(*sp))
+		return -EINVAL;
+
 	lock_sock(sk);
 
 	opt->src_addr = sp->sa_addr.pptp;
-- 
2.5.0
