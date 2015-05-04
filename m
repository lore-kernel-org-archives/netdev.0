From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 3/5] ipv4/ip_tunnel_core: Use eth_proto_is_802_3
Date: Mon, 04 May 2015 14:33:59 -0700
Message-ID: <20150504213359.2536.38833.stgit@ahduyck-vm-fedora22>
References: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277AbbEDVeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 17:34:07 -0400
In-Reply-To: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace "ntohs(proto) >= ETH_P_802_3_MIN" w/ eth_proto_is_802_3(proto).

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/ip_tunnel_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index ce63ab21b6cd..3998b1822d85 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -98,7 +98,7 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 			return -ENOMEM;
 
 		eh = (struct ethhdr *)skb->data;
-		if (likely(ntohs(eh->h_proto) >= ETH_P_802_3_MIN))
+		if (likely(eth_proto_is_802_3(eh->h_proto)))
 			skb->protocol = eh->h_proto;
 		else
 			skb->protocol = htons(ETH_P_802_2);
