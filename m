From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] openvswitch: Fix flow mask validation.
Date: Sun, 30 Nov 2014 23:04:17 -0800
Message-ID: <1417417457-1492-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:52558 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752426AbaLAHEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 02:04:24 -0500
Received: by mail-pd0-f170.google.com with SMTP id fp1so10350830pdb.29
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 23:04:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch fixes typo in the flow validation. This prevented
installation of ARP and IPv6 flows.

Fixes: 19e7a3df72 ("openvswitch: Fix NDP flow mask validation")
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_netlink.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 089b195..918e966 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -145,7 +145,7 @@ static bool match_validate(const struct sw_flow_match *match,
 	if (match->key->eth.type == htons(ETH_P_ARP)
 			|| match->key->eth.type == htons(ETH_P_RARP)) {
 		key_expected |= 1 << OVS_KEY_ATTR_ARP;
-		if (match->mask && (match->mask->key.tp.src == htons(0xff)))
+		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
 			mask_allowed |= 1 << OVS_KEY_ATTR_ARP;
 	}
 
@@ -220,7 +220,7 @@ static bool match_validate(const struct sw_flow_match *match,
 						htons(NDISC_NEIGHBOUR_SOLICITATION) ||
 				    match->key->tp.src == htons(NDISC_NEIGHBOUR_ADVERTISEMENT)) {
 					key_expected |= 1 << OVS_KEY_ATTR_ND;
-					if (match->mask && (match->mask->key.tp.src == htons(0xffff)))
+					if (match->mask && (match->mask->key.tp.src == htons(0xff)))
 						mask_allowed |= 1 << OVS_KEY_ATTR_ND;
 				}
 			}
-- 
1.7.1
