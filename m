From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmentation icmp v4 2/4] IPv4: skip ICMP for bridge contrack users when defrag expires
Date: Wed, 13 May 2015 19:28:00 -0700
Message-ID: <1431570482-9236-3-git-send-email-azhou@nicira.com>
References: <1431570482-9236-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:53209 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934163AbbENCtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 22:49:35 -0400
Received: by mail-pa0-f42.google.com with SMTP id wv17so69249939pac.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 19:49:31 -0700 (PDT)
In-Reply-To: <1431570482-9236-1-git-send-email-azhou@nicira.com>
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
index 83424f1..47fa64e 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -177,7 +177,9 @@ static bool frag_expire_skip_icmp(u32 user)
 {
 	return user == IP_DEFRAG_AF_PACKET ||
 	       ip_defrag_user_in_between(user, IP_DEFRAG_CONNTRACK_IN,
-					 __IP_DEFRAG_CONNTRACK_IN_END);
+					 __IP_DEFRAG_CONNTRACK_IN_END) ||
+	       ip_defrag_user_in_between(user, IP_DEFRAG_CONNTRACK_BRIDGE_IN,
+					 __IP_DEFRAG_CONNTRACK_BRIDGE_IN);
 }
 
 /*
-- 
1.9.1
