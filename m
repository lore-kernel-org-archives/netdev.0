From: kaber@trash.net
Subject: [PATCH 14/20] netfilter: ipset: take into account cidr value for the from address when creating the set
Date: Thu, 16 Jun 2011 21:47:14 +0200
Message-ID: <1308253640-29942-15-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64158 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932258Ab1FPTr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 15:47:27 -0400
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

When creating a set from a range expressed as a network like
10.1.1.172/29, the from address was taken as the IP address part and
not masked with the netmask from the cidr.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 3b5920b..4932311 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -478,6 +478,7 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 		if (cidr >= 32)
 			return -IPSET_ERR_INVALID_CIDR;
+		first_ip &= ip_set_hostmask(cidr);
 		last_ip = first_ip | ~ip_set_hostmask(cidr);
 	} else
 		return -IPSET_ERR_PROTOCOL;
-- 
1.7.2.3

