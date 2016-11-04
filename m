From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 6/7] l2tp: read IPv6 UDP checksum attributes from kernel
Date: Fri,  4 Nov 2016 23:11:10 +0000
Message-ID: <20161104231111.14677-6-asbjorn@asbjorn.st>
References: <20161104231111.14677-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:45935 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752794AbcKDXLr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 19:11:47 -0400
In-Reply-To: <20161104231111.14677-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of an older kernel that doesn't set L2TP_ATTR_UDP_ZERO_CSUM6_{R,T}X
the old hard-coded value is being preserved, since the attribute flag will be
missing.

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 ip/ipl2tp.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 6d00d09..8f3268d 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -296,12 +296,9 @@ static int get_response(struct nlmsghdr *n, void *arg)
 		p->l2spec_len = rta_getattr_u8(attrs[L2TP_ATTR_L2SPEC_LEN]);
 
 	p->udp_csum = !!attrs[L2TP_ATTR_UDP_CSUM];
-	/*
-	 * Not fetching from L2TP_ATTR_UDP_ZERO_CSUM6_{T,R}X because the
-	 * kernel doesn't send it so just leave it as default value.
-	 */
-	p->udp6_csum_tx = 1;
-	p->udp6_csum_rx = 1;
+	p->udp6_csum_tx = !attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX];
+	p->udp6_csum_rx = !attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX];
+
 	if (attrs[L2TP_ATTR_COOKIE])
 		memcpy(p->cookie, RTA_DATA(attrs[L2TP_ATTR_COOKIE]),
 		       p->cookie_len = RTA_PAYLOAD(attrs[L2TP_ATTR_COOKIE]));
-- 
2.10.1
