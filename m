From: Linsys Contractor Adhiraj Joshi <adhiraj@netxen.com>
Subject: [PATCH 2.6.21] NetXen: Fix hardware access for ppc architecture.
Date: Fri, 23 Mar 2007 07:21:24 -0800
Message-ID: <200703231521.l2NFLOu4023764@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:12990 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934282AbXCWPnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 11:43:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix for hardware access on big endian machine. 

Signed-off-by: Adhiraj Joshi <adhiraj@netxen.com>

---

 netxen_nic_init.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 229aa1c..eff965d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -438,6 +438,7 @@ do_rom_fast_read_words(struct netxen_ada
 
 	for (addridx = addr; addridx < (addr + size); addridx += 4) {
 		ret = do_rom_fast_read(adapter, addridx, (int *)bytes);
+		*(int *)bytes = cpu_to_le32(*(int *)bytes);
 		if (ret != 0)
 			break;
 		bytes += 4;
@@ -497,7 +498,7 @@ static inline int do_rom_fast_write_word
 		int timeout = 0;
 		int data;
 
-		data = *(u32*)bytes;
+		data = le32_to_cpu((*(u32*)bytes));
 
 		ret = do_rom_fast_write(adapter, addridx, data);
 		if (ret < 0)
