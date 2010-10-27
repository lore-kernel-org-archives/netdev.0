From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH] igb: Fix unused variable warning.
Date: Tue, 26 Oct 2010 17:56:03 -0700
Message-ID: <1288140963-20537-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:47658 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab0J0A4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 20:56:14 -0400
Received: by qyk10 with SMTP id 10so129041qyk.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 17:56:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit eab6d18d "vlan: Don't check for vlan group before
vlan_tx_tag_present" removed the need for the adapter variable
in igb_xmit_frame_ring_adv().  This removes the variable as well
to avoid the compiler warning.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/igb/igb_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 14db09e..892d196 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4107,7 +4107,6 @@ static inline int igb_maybe_stop_tx(struct igb_ring *tx_ring, int size)
 netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 				    struct igb_ring *tx_ring)
 {
-	struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
 	int tso = 0, count;
 	u32 tx_flags = 0;
 	u16 first;
-- 
1.7.1

