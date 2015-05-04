From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 2/5] ebtables: Use eth_proto_is_802_3
Date: Mon, 04 May 2015 14:33:54 -0700
Message-ID: <20150504213353.2536.70815.stgit@ahduyck-vm-fedora22>
References: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55000 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbbEDVd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 17:33:59 -0400
In-Reply-To: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace "ntohs(proto) >= ETH_P_802_3_MIN" w/ eth_proto_is_802_3(proto).

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/bridge/netfilter/ebtables.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 91180a7fc943..5149d9e71114 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -139,7 +139,7 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 		ethproto = h->h_proto;
 
 	if (e->bitmask & EBT_802_3) {
-		if (FWINV2(ntohs(ethproto) >= ETH_P_802_3_MIN, EBT_IPROTO))
+		if (FWINV2(eth_proto_is_802_3(ethproto), EBT_IPROTO))
 			return 1;
 	} else if (!(e->bitmask & EBT_NOPROTO) &&
 	   FWINV2(e->ethproto != ethproto, EBT_IPROTO))
