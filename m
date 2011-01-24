From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-2.6] bnx2: Always set ETH_FLAG_TXVLAN
Date: Mon, 24 Jan 2011 14:59:02 -0800
Message-ID: <1295909942-758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jesse@nicira.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1268 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab1AXXxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 18:53:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TSO does not work if the VLAN tag is in the packet (non-accelerated).
We may be able to remove this restriction in future firmware.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index df99edf..99e7652 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7553,6 +7553,10 @@ bnx2_set_flags(struct net_device *dev, u32 data)
 	    !(data & ETH_FLAG_RXVLAN))
 		return -EINVAL;
 
+	/* TSO with VLAN tag won't work with current firmware */
+	if (!(data & ETH_FLAG_TXVLAN))
+		return -EINVAL;
+
 	rc = ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH | ETH_FLAG_RXVLAN |
 				  ETH_FLAG_TXVLAN);
 	if (rc)
-- 
1.6.4.GIT


