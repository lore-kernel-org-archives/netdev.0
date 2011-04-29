From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/10] ipv4: Fetch route saddr from flow key in
 inet_sk_reselect_saddr().
Date: Fri, 29 Apr 2011 10:26:59 -0700 (PDT)
Message-ID: <20110429.102659.104043881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760407Ab1D2R1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:27:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id AA96E24C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:26:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that output route lookups update the flow with
source address selection, we can fetch it from
fl4->saddr instead of rt->rt_src

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/af_inet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 963a621..4e73499 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1122,7 +1122,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 
 	sk_setup_caps(sk, &rt->dst);
 
-	new_saddr = rt->rt_src;
+	new_saddr = fl4.saddr;
 
 	if (new_saddr == old_saddr)
 		return 0;
-- 
1.7.4.5

