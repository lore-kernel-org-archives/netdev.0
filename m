From: David Miller <davem@davemloft.net>
Subject: [PATCH]: net-2.6.26 IPv6 build fix
Date: Wed, 05 Mar 2008 20:58:53 -0800 (PST)
Message-ID: <20080305.205853.128294655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59676
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758611AbYCFE6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 23:58:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just checked the following build warning fix into
net-2.6.26

commit f59d43899e279c77924a7ada4bec8c70e5aeca06
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Mar 5 20:58:10 2008 -0800

    [IPV6]: Fix powerpc allmodconfig build warnings.
    
    Introduced by changeset 95e41e93e18d8e1e272ce23d96bae4f17ce11d42
    ("[IPV6]: Make ndisc_flow_init() common for later use.")
    
    Reported by Stephen Rothwell.
    
    In file included from net/ipv6/netfilter/ip6_tables.c:21:
    include/linux/icmpv6.h:192: warning: 'struct in6_addr' declared inside parameter list
    include/linux/icmpv6.h:192: warning: its scope is only this definition or declaration, which is probably not what you want
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index e4d4300..0306744 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -184,6 +184,7 @@ extern void				icmpv6_param_prob(struct sk_buff *skb,
 							  int code, int pos);
 
 struct flowi;
+struct in6_addr;
 extern void				icmpv6_flow_init(struct sock *sk,
 							 struct flowi *fl,
 							 u8 type,
