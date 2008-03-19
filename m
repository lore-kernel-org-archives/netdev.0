From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/3 net-2.6.26] Remove unnecessary check for opt->is_data in ip_options_compile.
Date: Wed, 19 Mar 2008 15:42:45 +0300
Message-ID: <1205930567-30956-1-git-send-email-den@openvz.org>
References: <1205930508.24116.14.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:63469 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752897AbYCTGkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 02:40:17 -0400
In-Reply-To: <1205930508.24116.14.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is the only way to reach ip_options compile with opt != NULL:

ip_options_get_finish
    opt->is_data = 1;
    ip_options_compile(opt, NULL)

So, checking for is_data inside opt != NULL branch is not needed.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/ip_options.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index df93a9c..7e94bf8 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -267,8 +267,7 @@ int ip_options_compile(struct ip_options * opt, struct sk_buff * skb)
 		optptr = iph + sizeof(struct iphdr);
 		opt->is_data = 0;
 	} else {
-		optptr = opt->is_data ? opt->__data :
-					(unsigned char *)&(ip_hdr(skb)[1]);
+		optptr = opt->__data;
 		iph = optptr - sizeof(struct iphdr);
 	}
 
-- 
1.5.3.rc5

