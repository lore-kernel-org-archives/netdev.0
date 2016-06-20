From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 14/19] ipv6: constify the skb pointer of ipv6_find_tlv().
Date: Mon, 20 Jun 2016 14:36:54 +0100
Message-ID: <1466429819-12707-15-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/ipv6.h      | 2 +-
 net/ipv6/exthdrs_core.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 22c7a37..3e59785 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -945,7 +945,7 @@ enum {
 int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset, int target,
 		  unsigned short *fragoff, int *fragflg);
 
-int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
+int ipv6_find_tlv(const struct sk_buff *skb, int offset, int type);
 
 struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 				const struct ipv6_txoptions *opt,
diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 9508a20..305e2ed 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -112,7 +112,7 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 }
 EXPORT_SYMBOL(ipv6_skip_exthdr);
 
-int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
+int ipv6_find_tlv(const struct sk_buff *skb, int offset, int type)
 {
 	const unsigned char *nh = skb_network_header(skb);
 	int packet_len = skb_tail_pointer(skb) - skb_network_header(skb);
-- 
2.7.4

