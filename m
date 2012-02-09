From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [patch] netxen_nic: signedness bug in netxen_md_entry_err_chk()
Date: Thu, 9 Feb 2012 01:27:58 -0600
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA81A886ECD2@MNEXMB1.qlogic.org>
References: <20120208092335.GC6554@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:12722
	"EHLO AM1EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751621Ab2BIH2e convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 02:28:34 -0500
In-Reply-To: <20120208092335.GC6554@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Dan for fixing this.

Rajesh
________________________________________
From: Dan Carpenter [dan.carpenter@oracle.com]
Sent: Wednesday, February 08, 2012 2:53 PM
To: Sony Chacko
Cc: Rajesh Borundia; netdev; kernel-janitors@vger.kernel.org
Subject: [patch] netxen_nic: signedness bug in netxen_md_entry_err_chk()

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
-                               struct netxen_minidump_entry *entry, u32 esize)
+                               struct netxen_minidump_entry *entry, int esize)
 {
        if (esize < 0) {
                entry->hdr.driver_flags |= NX_DUMP_SKIP;
