From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 5/5] vlan: Use eth_proto_is_802_3
Date: Mon, 04 May 2015 14:34:10 -0700
Message-ID: <20150504213410.2536.26437.stgit@ahduyck-vm-fedora22>
References: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55910 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbbEDVeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 17:34:17 -0400
In-Reply-To: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace "ntohs(proto) >= ETH_P_802_3_MIN" w/ eth_proto_is_802_3(proto).

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/if_vlan.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 920e4457ce6e..b9ab677c0c0a 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -539,7 +539,7 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
 	 */
 
 	proto = vhdr->h_vlan_encapsulated_proto;
-	if (ntohs(proto) >= ETH_P_802_3_MIN) {
+	if (eth_proto_is_802_3(proto)) {
 		skb->protocol = proto;
 		return;
 	}
