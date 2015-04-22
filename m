From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ixgbevf: pass the correct maxlen for eth_get_headlen()
Date: Wed, 22 Apr 2015 10:46:00 -0700
Message-ID: <1429724760-10075-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33704 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730AbbDVRqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 13:46:14 -0400
Received: by paboj16 with SMTP id oj16so279164908pab.0
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 10:46:14 -0700 (PDT)
In-Reply-To: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The second parameter of eth_get_headlen() is the length of
the frame buffer, not the header length of skb.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a16d267..c3526b3 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -676,7 +676,9 @@ static void ixgbevf_pull_tail(struct ixgbevf_ring *rx_ring,
 	/* we need the header to contain the greater of either ETH_HLEN or
 	 * 60 bytes if the skb->len is less than 60 for skb_pad.
 	 */
-	pull_len = eth_get_headlen(va, IXGBEVF_RX_HDR_SIZE);
+	pull_len = eth_get_headlen(va, skb_frag_size(frag));
+	if (unlikely(pull_len > IXGBEVF_RX_HDR_SIZE))
+		pull_len = IXGBEVF_RX_HDR_SIZE;
 
 	/* align pull length to size of long to optimize memcpy performance */
 	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
-- 
1.8.3.1
