From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Subject: RE: [patch] qed: signedness bug in qed_dcbx_process_tlv()
Date: Mon, 23 May 2016 11:06:05 +0000
Message-ID: <BY2PR1101MB11429E95A017F91699293F7A904E0@BY2PR1101MB1142.namprd11.prod.outlook.com>
References: <20160523101935.GA10712@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	Dept-Eng Everest Linux L2 <everest-linux-l2@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0136.outbound.protection.outlook.com ([65.55.169.136]:62176
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932395AbcEWLj2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 07:39:28 -0400
In-Reply-To: <20160523101935.GA10712@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Dan.
Acked-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

-----Original Message-----
From: Dan Carpenter [mailto:dan.carpenter@oracle.com] 
Sent: 23 May 2016 15:50
To: Yuval Mintz <Yuval.Mintz@qlogic.com>; Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Cc: Ariel Elior <Ariel.Elior@qlogic.com>; Dept-Eng Everest Linux L2 <everest-linux-l2@qlogic.com>; netdev <netdev@vger.kernel.org>; kernel-janitors@vger.kernel.org
Subject: [patch] qed: signedness bug in qed_dcbx_process_tlv()

"priority" needs to be signed for the error handling to work.

Fixes: 39651abd2814 ('qed: add support for dcbx.')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Applies to the main net tree.

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index cbf58e1..a06d19a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -192,9 +192,10 @@ qed_dcbx_process_tlv(struct qed_hwfn *p_hwfn,
 		     struct dcbx_app_priority_entry *p_tbl,
 		     u32 pri_tc_tbl, int count, bool dcbx_enabled)  {
-	u8 tc, priority, priority_map;
+	u8 tc, priority_map;
 	enum dcbx_protocol_type type;
 	u16 protocol_id;
+	int priority;
 	bool enable;
 	int i;
 
