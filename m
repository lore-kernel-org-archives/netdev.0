From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] xfrm: update flowi saddr in icmp_send if unset
Date: Fri, 5 Nov 2010 12:39:12 +0100
Message-ID: <20101105113912.GA14694@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-48.dex002.intermedia.net ([64.78.21.144]:38144 "EHLO
	dhost002-48.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751591Ab0KELyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 07:54:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

otherwise xfrm_lookup will fail to find correct policy

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 net/ipv4/icmp.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 96bc7f9..e5d1a44 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -569,6 +569,9 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		/* No need to clone since we're just using its address. */
 		rt2 = rt;
 
+		if (!fl.nl_u.ip4_u.saddr)
+			fl.nl_u.ip4_u.saddr = rt->rt_src;
+
 		err = xfrm_lookup(net, (struct dst_entry **)&rt, &fl, NULL, 0);
 		switch (err) {
 		case 0:
-- 
1.7.1

