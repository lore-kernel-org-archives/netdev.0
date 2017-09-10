From: David Lebrun <target0@geeknode.org>
Subject: [PATCH net] ipv6: sr: remove duplicate routing header type check
Date: Sun, 10 Sep 2017 13:45:39 +0100
Message-ID: <20170910124539.13808-1-dlebrun@google.com>
Cc: David Lebrun <dav.lebrun@gmail.com>,
        David Lebrun <dlebrun@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34322 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751469AbdIJMon (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 08:44:43 -0400
Received: by mail-wm0-f65.google.com with SMTP id l19so4828913wmi.1
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 05:44:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <dav.lebrun@gmail.com>

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
