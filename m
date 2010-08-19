From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [RFC Patch] netxen: remove firmware exports
Date: Thu, 19 Aug 2010 04:12:51 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F86E69208@MNEXMB2.qlogic.org>
References: <20100818095908.6606.56224.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	Narender Kumar <narender.kumar@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Amerigo Wang <amwang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:12066 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab0HSJM7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 05:12:59 -0400
In-Reply-To: <20100818095908.6606.56224.sendpatchset@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> netxen_nic driver can store firmwares on flash, and get them porperly and
> dynamically, so the firmwares may not appear in /lib/firmware/. However, netxen_nic
> still exports these firmwares via modinfo, this makes our script which parses
> modinfo output fail.

NX_UNIFIED_ROMIMAGE_NAME(phanfw.bin) is already submitted and we won't submit any other fw files.

> -MODULE_FIRMWARE(NX_P2_MN_ROMIMAGE_NAME);
> -MODULE_FIRMWARE(NX_P3_CT_ROMIMAGE_NAME);
> -MODULE_FIRMWARE(NX_P3_MN_ROMIMAGE_NAME);

It's not compulsory to submit firmware files which are exported (MODULE_FIRMWARE).
I am leaving this upto David to decide about this patch.

-Amit

-----Original Message-----
From: Amerigo Wang [mailto:amwang@redhat.com] 
Sent: Wednesday, August 18, 2010 3:25 PM
To: linux-kernel@vger.kernel.org
Cc: Dhananjay Phadke; Amit Salecha; Narender Kumar; netdev@vger.kernel.org; David S. Miller; Amerigo Wang
Subject: [RFC Patch] netxen: remove firmware exports


netxen_nic driver can store firmwares on flash, and get them porperly and
dynamically, so the firmwares may not appear in /lib/firmware/. However, netxen_nic
still exports these firmwares via modinfo, this makes our script which parses
modinfo output fail.

Probably netxen_nic has other way to export these firmwares, but not like other
modules in a stardand way. I think we can just remove these exports, but
I am not sure.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Cc: Narender Kumar <narender.kumar@qlogic.com>

---
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index fd86e18..e8443af 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -41,10 +41,6 @@
 MODULE_DESCRIPTION("QLogic/NetXen (1/10) GbE Converged Ethernet Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
-MODULE_FIRMWARE(NX_P2_MN_ROMIMAGE_NAME);
-MODULE_FIRMWARE(NX_P3_CT_ROMIMAGE_NAME);
-MODULE_FIRMWARE(NX_P3_MN_ROMIMAGE_NAME);
-MODULE_FIRMWARE(NX_UNIFIED_ROMIMAGE_NAME);
 
 char netxen_nic_driver_name[] = "netxen_nic";
 static char netxen_nic_driver_string[] = "QLogic/NetXen Network Driver v"

