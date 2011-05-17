From: kaber@trash.net
Subject: [PATCH 1/2] netfilter: nf_ct_sip: validate Content-Length in TCP SIP messages
Date: Tue, 17 May 2011 07:26:53 +0200
Message-ID: <1305610014-3056-2-git-send-email-kaber@trash.net>
References: <1305610014-3056-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1305610014-3056-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Verify that the message length of a single SIP message, which is calculated
based on the Content-Length field contained in the SIP message, does not
exceed the packet boundaries.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_sip.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index bcf47eb..1f81abd 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1461,6 +1461,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
 		end += strlen("\r\n\r\n") + clen;
 
 		msglen = origlen = end - dptr;
+		if (msglen > datalen)
+			return NF_DROP;
 
 		ret = process_sip_msg(skb, ct, dataoff, &dptr, &msglen);
 		if (ret != NF_ACCEPT)
-- 
1.7.2.3

