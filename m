From: Toby DiPasquale <toby@cbcg.net>
Subject: [PATCH] off-by-one in DecodeQ931
Date: Sat, 23 Apr 2016 13:08:33 -0400
Message-ID: <CAML0wpEBwXdzWX7g3LDJRDOVM0J7dkuhH8b+96ZhRf54+qUgwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: pablo@netfilter.org, Patrick McHardy <kaber@trash.net>,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was reviewing the H.323 conntrack helper in the kernel when I came
across what appears to be an off-by-one error in the DecodeQ931
function. The MessageType field of the Q931 record is assigned and p
is incremented, but the corresponding decrement to sz is missing,
leading the sz variable to be one more than it should be. This patch
decrements sz so it is the proper value going into the parsing of the
information elements.

Signed-off-by: Toby DiPasquale <toby@cbcg.net>
--
diff --git a/net/netfilter/nf_conntrack_h323_asn1.c
b/net/netfilter/nf_conntrack_h323_asn1.c
index bcd5ed6..68b1557 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -849,6 +849,7 @@ int DecodeQ931(unsigned char *buf, size_t sz, Q931 *q931)
        if (sz < 1)
                return H323_ERROR_BOUND;
        q931->MessageType = *p++;
+       sz--;
        PRINT("MessageType = %02X\n", q931->MessageType);
        if (*p & 0x80) {
                p++;


-- 
Toby DiPasquale
