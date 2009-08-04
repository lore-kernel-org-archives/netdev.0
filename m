From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: [3/6] vxge: improve tx performance by using mmiowb() instead of
	wmb()
Date: Tue, 4 Aug 2009 16:21:21 -0400
Message-ID: <20090804202121.GD9924@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33059 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932456AbZHDUj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:39:57 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id 2AD952065B9F
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2009 16:21:23 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id 7pAkUvFwD5HpuEws for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 16:21:23 -0400 (EDT)
Received: from neterion.com ([10.16.18.36])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n74KLLmd013286
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:21:22 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wmb() is extremely heavy on x86.  The semantics required in the driver are 
provided by mmiowb(), so use that and improve tx performance on P4 Xeons by 
5-10%.

Signed-off-by: Benjamin LaHaise <ben.lahaise@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 370f55c..0efb769 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -1070,11 +1070,11 @@ static void __vxge_hw_non_offload_db_post(struct __vxge_hw_fifo *fifo,
 		VXGE_HW_NODBW_GET_NO_SNOOP(no_snoop),
 		&fifo->nofl_db->control_0);
 
-	wmb();
+	mmiowb();
 
 	writeq(txdl_ptr, &fifo->nofl_db->txdl_ptr);
-	wmb();
 
+	mmiowb();
 }
 
 /**
