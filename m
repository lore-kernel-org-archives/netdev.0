From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] qed: potential overflow in qed_cxt_src_t2_alloc()
Date: Tue, 7 Jun 2016 15:04:16 +0300
Message-ID: <20160607120416.GA2175@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <Ariel.Elior@qlogic.com>, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44344 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbcFGME2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 08:04:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current code "ent_per_page" could be more than "conn_num" making
"conn_num" negative after the subtraction.  In the next iteration
through the loop then the negative is treated as a very high positive
meaning we don't put a limit on "ent_num".  It could lead to memory
corruption.

Fixes: dbb799c39717 ('qed: Initialize hardware for new protocols')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index d85b7ba..1c35f37 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -850,7 +850,7 @@ static int qed_cxt_src_t2_alloc(struct qed_hwfn *p_hwfn)
 			val = 0;
 		entries[j].next = cpu_to_be64(val);
 
-		conn_num -= ent_per_page;
+		conn_num -= ent_num;
 	}
 
 	return 0;
