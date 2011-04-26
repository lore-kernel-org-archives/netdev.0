From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 7/7] sctp: fix IPv6 source address output routing
 with IPsec
Date: Tue, 26 Apr 2011 11:49:26 +0800
Message-ID: <4DB640C6.30209@cn.fujitsu.com>
References: <4DB63F85.2090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56706 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757979Ab1DZDtj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 23:49:39 -0400
In-Reply-To: <4DB63F85.2090609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When do IPv6 source address output routing, the flowi6_proto
field is missing, different router will be return under IPsec.
This patch fixed it.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/ipv6.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index cbbfe20..180495e 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -265,6 +265,7 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	memset(fl6, 0, sizeof(struct flowi6));
 	ipv6_addr_copy(&fl6->daddr, &daddr->v6.sin6_addr);
 	fl6->fl6_dport = daddr->v6.sin6_port;
+	fl6->flowi6_proto = IPPROTO_SCTP;
 	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
 		fl6->flowi6_oif = daddr->v6.sin6_scope_id;
 
-- 
1.6.5.2


