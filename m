From: Alexey Dobriyan <adobriyan@openvz.org>
Subject: [PATCH] igmp: check add_grhead() return value
Date: Mon, 5 Feb 2007 18:04:33 +0300
Message-ID: <20070205150432.GA5961@localhost.sw.ru>
References: <20070130105701.GA6015@localhost.sw.ru> <OF52248A96.35A5CA3C-ON88257273.003E5791-88257273.003F9122@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:14480 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932994AbXBEO77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 09:59:59 -0500
Content-Disposition: inline
In-Reply-To: <OF52248A96.35A5CA3C-ON88257273.003E5791-88257273.003F9122@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, now that we aren't seeing crashes which can be attributed to these
NULL dereferences any longer.
--------------------------------------
add_grhead() allocates memory with GFP_ATOMIC and in at least two places skb
from it passed to skb_put() without checking.

Signed-off-by: Alexey Dobriyan <adobriyan@openvz.org>
---

 net/ipv4/igmp.c  |    2 ++
 net/ipv6/mcast.c |    2 ++
 2 files changed, 4 insertions(+)

--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -455,6 +455,8 @@ static struct sk_buff *add_grec(struct s
 			skb = add_grhead(skb, pmc, type, &pgr);
 			first = 0;
 		}
+		if (!skb)
+			return NULL;
 		psrc = (__be32 *)skb_put(skb, sizeof(__be32));
 		*psrc = psf->sf_inaddr;
 		scount++; stotal++;
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1582,6 +1582,8 @@ static struct sk_buff *add_grec(struct s
 			skb = add_grhead(skb, pmc, type, &pgr);
 			first = 0;
 		}
+		if (!skb)
+			return NULL;
 		psrc = (struct in6_addr *)skb_put(skb, sizeof(*psrc));
 		*psrc = psf->sf_addr;
 		scount++; stotal++;

