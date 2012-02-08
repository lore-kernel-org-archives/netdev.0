From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netxen_nic: signedness bug in netxen_md_entry_err_chk()
Date: Wed, 8 Feb 2012 12:23:36 +0300
Message-ID: <20120208092335.GC6554@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:30134 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab2BHJXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 04:23:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"esize" should be signed because it can be negative here.  For example,
when we call it in netxen_parse_md_template(), it could be -1 from the
return value of netxen_md_L2Cache().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index 0a81228..6f37470 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -2354,7 +2354,7 @@ netxen_md_rdqueue(struct netxen_adapter *adapter,
 */
 
 static int netxen_md_entry_err_chk(struct netxen_adapter *adapter,
-				struct netxen_minidump_entry *entry, u32 esize)
+				struct netxen_minidump_entry *entry, int esize)
 {
 	if (esize < 0) {
 		entry->hdr.driver_flags |= NX_DUMP_SKIP;
