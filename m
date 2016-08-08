From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH 2/3] net: Replace for_each_possible_cpu with for_each_online_cpu
Date: Mon,  8 Aug 2016 18:22:21 +0800
Message-ID: <1470651742-15195-3-git-send-email-hejianet@gmail.com>
References: <1470651742-15195-1-git-send-email-hejianet@gmail.com>
Cc: linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35483 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbcHHKWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 06:22:53 -0400
In-Reply-To: <1470651742-15195-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In PowerPC server with large number cpus, the loop index in smt=1 could be 
reduced to 1/8 compared with smt=8.
Thus cache misses can be reduced.

Signed-off-by: Jia He <hejianet@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 43fa8d0..1fce613 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4969,7 +4969,7 @@ static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
 
 	buff[0] = IPSTATS_MIB_MAX;
 
-	for_each_possible_cpu(c) {
+	for_each_online_cpu(c) {
 		for (i = 1; i < IPSTATS_MIB_MAX; i++)
 			buff[i] += snmp_get_cpu_field64(mib, c, i, syncpoff);
 	}
-- 
2.5.0
