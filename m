From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 5/5] net: add FCLONE_SCRATCH use to ipv6 udp path
Date: Thu, 27 Oct 2011 15:53:41 -0400
Message-ID: <1319745221-30880-6-git-send-email-nhorman@tuxdriver.com>
References: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Cc: root <root@amd-dinar-01.lab.bos.redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38420 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab1J0Tyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 15:54:40 -0400
In-Reply-To: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: root <root@amd-dinar-01.lab.bos.redhat.com>

Like the ipv4 path, the ipv6 path can benefit from this change by taking
advantage of the unused space at the tail of an skbuffs data area.  Mark ipv6
udp multicast frames as being elligible for scratch fcloning.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/ipv6/udp.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f4ca0a5..dda6661 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -645,6 +645,8 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif;
 	unsigned int i, count = 0;
 
+	skb_make_fclone_scratch(skb);
+
 	spin_lock(&hslot->lock);
 	sk = sk_nulls_head(&hslot->head);
 	dif = inet6_iif(skb);
-- 
1.7.6.4
