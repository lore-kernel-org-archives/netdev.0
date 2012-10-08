From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] cxgb4: allocate enough data in t4_memory_rw()
Date: Mon, 8 Oct 2012 10:12:11 +0300
Message-ID: <20121008071210.GA17400@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>,
	Vipul Pandya <vipul@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:49005 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549Ab2JHHMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 03:12:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MEMWIN0_APERTURE is the size in bytes.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This was introduced in 8c357ebd569 "cxgb4: Dynamically allocate memory
in t4_memory_rw() and get_vpd_params()" from Oct 3.

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 137a244..e914c41 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -417,7 +417,7 @@ static int t4_memory_rw(struct adapter *adap, int mtype, u32 addr, u32 len,
 	if ((addr & 0x3) || (len & 0x3))
 		return -EINVAL;
 
-	data = vmalloc(MEMWIN0_APERTURE/sizeof(__be32));
+	data = vmalloc(MEMWIN0_APERTURE);
 	if (!data)
 		return -ENOMEM;
 
