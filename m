From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v2 2/5] net: Extend struct flowi6 with multipath hash
Date: Fri, 28 Oct 2016 14:32:32 +0200
Message-ID: <1477657955-5157-3-git-send-email-jkbs@redhat.com>
References: <1477657955-5157-1-git-send-email-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38871 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756275AbcJ1Mck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 08:32:40 -0400
Received: by mail-wm0-f46.google.com with SMTP id n67so110943414wme.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 05:32:39 -0700 (PDT)
In-Reply-To: <1477657955-5157-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow for functions that fill out the IPv6 flow info to also pass a hash
computed over the skb contents. The hash value will drive the multipath
routing decisions.

This is intended for special treatment of ICMPv6 errors, where we would
like to make a routing decision based on the flow identifying the
offending IPv6 datagram that triggered the error, rather than the flow
of the ICMP error itself.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/flow.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/flow.h b/include/net/flow.h
index 035aa77..73ee3aa 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -143,6 +143,7 @@ struct flowi6 {
 #define fl6_ipsec_spi		uli.spi
 #define fl6_mh_type		uli.mht.type
 #define fl6_gre_key		uli.gre_key
+	__u32			mp_hash;
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 struct flowidn {
-- 
2.7.4
