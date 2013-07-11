From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net] bnx2x: fix tunneling CSUM calculation
Date: Thu, 11 Jul 2013 15:48:21 +0300
Message-ID: <1373546901-26741-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexander.h.duyck@intel.com,
	pshelar@nicira.com, xiyou.wangcong@gmail.com, eilong@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3494 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754538Ab3GKMsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jul 2013 08:48:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit c957d09ffda417f6c8e3d1f10e2b05228607d6d7
"bnx2x: Remove sparse and coccinelle warnings"
driver provided wrong partial csum for HW in tunneing
scenarios.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Pravin Shelar <pshelar@nicira.com>
CC: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 3353efe..ee350bd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3543,9 +3543,9 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 	/* outer IP header info */
 	if (xmit_type & XMIT_CSUM_V4) {
 		struct iphdr *iph = ip_hdr(skb);
-		u16 csum = (__force u16)(~iph->check) -
-			   (__force u16)iph->tot_len -
-			   (__force u16)iph->frag_off;
+		u32 csum = (__force u32)(~iph->check) -
+			   (__force u32)iph->tot_len -
+			   (__force u32)iph->frag_off;
 
 		pbd2->fw_ip_csum_wo_len_flags_frag =
 			bswab16(csum_fold((__force __wsum)csum));
-- 
1.8.1.4
