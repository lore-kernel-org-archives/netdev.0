From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/7] ipv4: Use flowi4_init_output() in raw_sendmsg()
Date: Thu, 31 Mar 2011 17:12:19 -0700 (PDT)
Message-ID: <20110331.171219.102557860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759531Ab1DAAM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 20:12:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id ED29F24C089
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 17:12:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/raw.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2d3c72e..7d32d9d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -548,17 +548,13 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 
 	{
-		struct flowi4 fl4 = {
-			.flowi4_oif = ipc.oif,
-			.flowi4_mark = sk->sk_mark,
-			.daddr = daddr,
-			.saddr = saddr,
-			.flowi4_tos = tos,
-			.flowi4_proto = (inet->hdrincl ?
-					 IPPROTO_RAW :
-					 sk->sk_protocol),
-			.flowi4_flags = FLOWI_FLAG_CAN_SLEEP,
-		};
+		struct flowi4 fl4;
+
+		flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
+				   RT_SCOPE_UNIVERSE,
+				   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
+				   FLOWI_FLAG_CAN_SLEEP, daddr, saddr, 0, 0);
+
 		if (!inet->hdrincl) {
 			err = raw_probe_proto_opt(&fl4, msg);
 			if (err)
-- 
1.7.4.2

