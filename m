From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] qed: Fix setting/clearing bit in completion bitmap
Date: Mon, 25 Jul 2016 19:07:46 +0300
Message-ID: <1469462866-14103-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Manish Chopra <manish.chopra@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:15841 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752476AbcGYQH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 12:07:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

Slowpath completion handling is incorrectly changing
SPQ_RING_SIZE bits instead of a single one.

Fixes: 76a9a3642a0b ("qed: fix handling of concurrent ramrods")
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed_spq.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index b122f60..03601df 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -809,13 +809,12 @@ int qed_spq_completion(struct qed_hwfn *p_hwfn,
 			 * in a bitmap and increasing the chain consumer only
 			 * for the first successive completed entries.
 			 */
-			bitmap_set(p_spq->p_comp_bitmap, pos, SPQ_RING_SIZE);
+			__set_bit(pos, p_spq->p_comp_bitmap);
 
 			while (test_bit(p_spq->comp_bitmap_idx,
 					p_spq->p_comp_bitmap)) {
-				bitmap_clear(p_spq->p_comp_bitmap,
-					     p_spq->comp_bitmap_idx,
-					     SPQ_RING_SIZE);
+				__clear_bit(p_spq->comp_bitmap_idx,
+					    p_spq->p_comp_bitmap);
 				p_spq->comp_bitmap_idx++;
 				qed_chain_return_produced(&p_spq->chain);
 			}
-- 
2.7.2
