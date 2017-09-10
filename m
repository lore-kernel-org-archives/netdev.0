From: David Lebrun <dav.lebrun@gmail.com>
Subject: [PATCH net] ipv6: sr: remove duplicate routing header type check
Date: Sun, 10 Sep 2017 14:22:01 +0100
Message-ID: <20170910132201.15576-1-dav.lebrun@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35333 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751482AbdIJNV1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 09:21:27 -0400
Received: by mail-wr0-f194.google.com with SMTP id n64so3240550wrb.2
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 06:21:26 -0700 (PDT)
Received: from localhost.localdomain (shingan.ethylix.be. [194.110.69.82])
        by smtp.gmail.com with ESMTPSA id r16sm11085591wrb.43.2017.09.10.06.21.25
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 10 Sep 2017 06:21:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <dlebrun@google.com>

As seg6_validate_srh() already checks that the Routing Header type is
correct, it is not necessary to do it again in get_srh().

Fixes: 5829d70b ("ipv6: sr: fix get_srh() to comply with IPv6 standard "RFC 8200")
Signed-off-by: David Lebrun <dlebrun@google.com>
---
 net/ipv6/seg6_local.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index 7ff54db..825b8e0 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -72,10 +72,6 @@ static struct ipv6_sr_hdr *get_srh(struct sk_buff *skb)
 
 	srh = (struct ipv6_sr_hdr *)(skb->data + srhoff);
 
-	/* make sure it's a Segment Routing header (Routing Type 4) */
-	if (srh->type != IPV6_SRCRT_TYPE_4)
-		return NULL;
-
 	len = (srh->hdrlen + 1) << 3;
 
 	if (!pskb_may_pull(skb, srhoff + len))
-- 
2.10.2
