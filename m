From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 06/13] e1000: remove open-coded skb_cow_head
Date: Fri, 11 Apr 2014 06:52:56 -0700
Message-ID: <1397224383-19269-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755768AbaDKNxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 09:53:11 -0400
In-Reply-To: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 46e6544..27058df 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2682,14 +2682,13 @@ static int e1000_tso(struct e1000_adapter *adapter,
 	u32 cmd_length = 0;
 	u16 ipcse = 0, tucse, mss;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
-	int err;
 
 	if (skb_is_gso(skb)) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
+		int err;
+
+		err = skb_cow_head(skb, 0);
+		if (err < 0)
+			return err;
 
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		mss = skb_shinfo(skb)->gso_size;
-- 
1.9.0
