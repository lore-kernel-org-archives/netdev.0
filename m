From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fixes static checker warning in mps_tcam_show()
Date: Fri,  8 Jan 2016 12:21:25 +0530
Message-ID: <1452235885-28129-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:62512 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750766AbcAHGuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 01:50:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 115b56af88b5 ("cxgb4: Update mps_tcam output to include T6
fields") from Dec 23, 2015, leads to the following static checker
warning:

        drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c:1735
mps_tcam_show()
        warn: we tested 'lookup_type' before and it was 'true'

Fixing it.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 1bab34f..e6a4072 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1726,13 +1726,13 @@ static int mps_tcam_show(struct seq_file *seq, void *v)
 				seq_printf(seq,
 					   "%3u %02x:%02x:%02x:%02x:%02x:%02x "
 					   "%012llx %06x %06x    -    -   %3c"
-					   "      %3c  %4x   "
+					   "      'I'  %4x   "
 					   "%3c   %#x%4u%4d", idx, addr[0],
 					   addr[1], addr[2], addr[3],
 					   addr[4], addr[5],
 					   (unsigned long long)mask,
 					   vniy, vnix, dip_hit ? 'Y' : 'N',
-					   lookup_type ? 'I' : 'O', port_num,
+					   port_num,
 					   (cls_lo & T6_SRAM_VLD_F) ? 'Y' : 'N',
 					   PORTMAP_G(cls_hi),
 					   T6_PF_G(cls_lo),
-- 
2.3.4
