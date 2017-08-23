From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v3 1/4] net: Extend struct flowi6 with multipath hash
Date: Wed, 23 Aug 2017 09:58:28 +0200
Message-ID: <20170823075831.27031-2-jkbs@redhat.com>
References: <20170823075831.27031-1-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34805 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753420AbdHWH6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:58:36 -0400
Received: by mail-wm0-f50.google.com with SMTP id r187so4630143wma.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 00:58:36 -0700 (PDT)
In-Reply-To: <20170823075831.27031-1-jkbs@redhat.com>
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
---
 include/net/flow.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/flow.h b/include/net/flow.h
index f3dc61b..eb60cee3 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -149,6 +149,7 @@ struct flowi6 {
 #define fl6_ipsec_spi		uli.spi
 #define fl6_mh_type		uli.mht.type
 #define fl6_gre_key		uli.gre_key
+	__u32			mp_hash;
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 struct flowidn {
-- 
2.9.4
