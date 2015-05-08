From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmentation icmp v3 2/4] IPv4: skip ICMP for bridge contrack users when defrag expires
Date: Thu,  7 May 2015 21:26:37 -0700
Message-ID: <1431059199-7139-3-git-send-email-azhou@nicira.com>
References: <1431059199-7139-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:47455 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751284AbbEHEsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 00:48:17 -0400
Received: by mail-pd0-f172.google.com with SMTP id a3so63065951pde.3
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 21:48:16 -0700 (PDT)
In-Reply-To: <1431059199-7139-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

users in [IP_DEFRAG_CONNTRACK_BRIDGE_IN, __IP_DEFRAG_CONNTRACK_BR_IN]
should not ICMP message also.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/ipv4/ip_fragment.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 429cefa..3061ca8 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -177,7 +177,9 @@ static bool frag_expire_skip_icmp(u32 user)
 {
 	return (user == IP_DEFRAG_AF_PACKET ||
 		ip_defrag_user_in_between(user, IP_DEFRAG_CONNTRACK_IN,
-					  __IP_DEFRAG_CONNTRACK_IN_END));
+					  __IP_DEFRAG_CONNTRACK_IN_END) ||
+		ip_defrag_user_in_between(user, IP_DEFRAG_CONNTRACK_BRIDGE_IN,
+					  __IP_DEFRAG_CONNTRACK_BRIDGE_IN));
 }
 
 /*
-- 
1.9.1
