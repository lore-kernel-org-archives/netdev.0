From: kaber@trash.net
Subject: [PATCH 2/6] netfilter: nf_ct_sip: default to NF_ACCEPT in sip_help_tcp()
Date: Wed, 22 Sep 2010 09:17:30 +0200
Message-ID: <1285139854-11827-3-git-send-email-kaber@trash.net>
References: <1285139854-11827-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1285139854-11827-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

I initially noticed this because of the compiler warning below, but it
does seem to be a valid concern in the case where ct_sip_get_header()
returns 0 in the first iteration of the while loop.

net/netfilter/nf_conntrack_sip.c: In function 'sip_help_tcp':
net/netfilter/nf_conntrack_sip.c:1379: warning: 'ret' may be used uninitialized in this function

Signed-off-by: Simon Horman <horms@verge.net.au>
[Patrick: changed NF_DROP to NF_ACCEPT]
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_sip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 53d8922..f64de95 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1376,7 +1376,7 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 	unsigned int msglen, origlen;
 	const char *dptr, *end;
 	s16 diff, tdiff = 0;
-	int ret;
+	int ret = NF_ACCEPT;
 	typeof(nf_nat_sip_seq_adjust_hook) nf_nat_sip_seq_adjust;
 
 	if (ctinfo != IP_CT_ESTABLISHED &&
-- 
1.7.1

