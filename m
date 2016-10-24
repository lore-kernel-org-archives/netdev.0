From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next 2/5] net: Extend struct flowi6 with multipath hash
Date: Mon, 24 Oct 2016 11:28:49 +0200
Message-ID: <1477301332-23954-3-git-send-email-jkbs@redhat.com>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
