From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 5/5] eth: Pull header from first fragment via
 eth_get_headlen
Date: Wed, 24 Feb 2016 09:30:04 -0800
Message-ID: <20160224173004.12339.17023.stgit@localhost.localdomain>
References: <20160224172644.12339.92679.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36476 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758161AbcBXRaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:30:05 -0500
Received: by mail-pa0-f41.google.com with SMTP id yy13so15946399pab.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 09:30:05 -0800 (PST)
In-Reply-To: <20160224172644.12339.92679.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to try and pull the L4 header in if it is available in the first
fragment.  As such add the flag to indicate we want to pull the headers on
the first fragment in.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ethernet/eth.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 103871784e50..66dff5e3d772 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -125,6 +125,7 @@ EXPORT_SYMBOL(eth_header);
  */
 u32 eth_get_headlen(void *data, unsigned int len)
 {
+	const unsigned int flags = FLOW_DISSECTOR_F_PARSE_1ST_FRAG;
 	const struct ethhdr *eth = (const struct ethhdr *)data;
 	struct flow_keys keys;
 
@@ -134,7 +135,7 @@ u32 eth_get_headlen(void *data, unsigned int len)
 
 	/* parse any remaining L2/L3 headers, check for L4 */
 	if (!skb_flow_dissect_flow_keys_buf(&keys, data, eth->h_proto,
-					    sizeof(*eth), len, 0))
+					    sizeof(*eth), len, flags))
 		return max_t(u32, keys.control.thoff, sizeof(*eth));
 
 	/* parse for any L4 headers */
