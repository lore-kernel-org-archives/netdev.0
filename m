From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 2/2] ipv6: Fix build error with udp_offload
Date: Thu, 15 Nov 2012 21:35:37 -0500
Message-ID: <1353033337-2772-1-git-send-email-vyasevic@redhat.com>
References: <50a584d5.9dutnkC1pLuFHpWQ%fengguang.wu@intel.com>
Cc: davem@davemloft.net, fengguang.wu@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804Ab2KPCfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 21:35:39 -0500
In-Reply-To: <50a584d5.9dutnkC1pLuFHpWQ%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ip6_checksum.h include.  This should resolve the following issue
that shows up on power:

net/ipv6/udp_offload.c: In function 'udp6_ufo_send_check':
net/ipv6/udp_offload.c:29:2: error: implicit declaration of function
'csum_ipv6_magic' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/ipv6/udp_offload.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 8e01c44..0c8934a 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -13,6 +13,7 @@
 #include <net/protocol.h>
 #include <net/ipv6.h>
 #include <net/udp.h>
+#include <net/ip6_checksum.h>
 #include "ip6_offload.h"
 
 static int udp6_ufo_send_check(struct sk_buff *skb)
-- 
1.7.7.6
