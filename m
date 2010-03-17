From: cooldavid@cooldavid.org
Subject: [PATCH net-2.6 1/3] jme: Fix VLAN memory leak
Date: Wed, 17 Mar 2010 18:09:29 +0800
Message-ID: <1268820571-2092-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Hsiu-Che Chao" <hcchao@jmicron.com>, stable@kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:35758 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754111Ab0CQKPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 06:15:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Fix memory leak while receiving 8021q tagged packet which is not
registered by user.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
Cc: stable@kernel.org
---
 drivers/net/jme.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 0f31497..cfc7b98 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -946,6 +946,8 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, int idx)
 				jme->jme_vlan_rx(skb, jme->vlgrp,
 					le16_to_cpu(rxdesc->descwb.vlan));
 				NET_STAT(jme).rx_bytes += 4;
+			} else {
+				dev_kfree_skb(skb);
 			}
 		} else {
 			jme->jme_rx(skb);
-- 
1.6.4.4

