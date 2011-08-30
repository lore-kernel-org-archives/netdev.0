From: kaber@trash.net
Subject: [PATCH 5/8] netfilter: nf_ct_pptp: fix DNATed PPTP connection address translation
Date: Tue, 30 Aug 2011 16:41:18 +0200
Message-ID: <1314715281-26233-6-git-send-email-kaber@trash.net>
References: <1314715281-26233-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1314715281-26233-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sanket Shah <sanket.shah@elitecore.com>

When both the server and the client are NATed, the set-link-info control
packet containing the peer's call-id field is not properly translated.

I have verified that it was working in 2.6.16.13 kernel previously but
due to rewrite, this scenario stopped working (Not knowing exact version
when it stopped working).

Signed-off-by: Sanket Shah <sanket.shah@elitecore.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_pptp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 2fd4565..31d56b2 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -364,6 +364,7 @@ pptp_inbound_pkt(struct sk_buff *skb,
 		break;
 
 	case PPTP_WAN_ERROR_NOTIFY:
+	case PPTP_SET_LINK_INFO:
 	case PPTP_ECHO_REQUEST:
 	case PPTP_ECHO_REPLY:
 		/* I don't have to explain these ;) */
-- 
1.7.2.3

