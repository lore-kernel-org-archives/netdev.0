From: kaber@trash.net
Subject: [PATCH 13/20] netfilter: ipset: adding ranges to hash types with timeout could still fail, fixed
Date: Thu, 16 Jun 2011 21:47:13 +0200
Message-ID: <1308253640-29942-14-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64142 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253Ab1FPTr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 15:47:26 -0400
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The patch "Fix adding ranges to hash types" had got a mistypeing
in the timeout variant of the hash types, which actually made
the patch ineffective. Fixed!

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 905e2ac..a099d40 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -835,7 +835,7 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	}
 	ret = type_pf_elem_tadd(n, d, timeout);
 	if (ret != 0) {
-		if (ret == -EEXIST)
+		if (ret == -EAGAIN)
 			type_pf_data_next(h, d);
 		goto out;
 	}
-- 
1.7.2.3

