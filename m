From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 06/22] e1000: minor tso ipv6 cleanups
Date: Fri, 08 Dec 2006 15:02:57 -0800
Message-ID: <20061208230257.30109.63706.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4382 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761256AbWLHWw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:52:59 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Zero descriptor ip_config field and use skb_shinfo to detect IPV6 packet.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f39b244..dc76e01 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2780,7 +2780,7 @@ e1000_tso(struct e1000_adapter *adapter,
 			cmd_length = E1000_TXD_CMD_IP;
 			ipcse = skb->h.raw - skb->data - 1;
 #ifdef NETIF_F_TSO6
-		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
 			skb->nh.ipv6h->payload_len = 0;
 			skb->h.th->check =
 				~csum_ipv6_magic(&skb->nh.ipv6h->saddr,
@@ -2843,6 +2843,7 @@ e1000_tx_csum(struct e1000_adapter *adap
 		buffer_info = &tx_ring->buffer_info[i];
 		context_desc = E1000_CONTEXT_DESC(*tx_ring, i);
 
+		context_desc->lower_setup.ip_config = 0;
 		context_desc->upper_setup.tcp_fields.tucss = css;
 		context_desc->upper_setup.tcp_fields.tucso = css + skb->csum_offset;
 		context_desc->upper_setup.tcp_fields.tucse = 0;



---
Auke Kok <auke-jan.h.kok@intel.com>
