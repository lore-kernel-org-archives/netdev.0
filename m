From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH 3] scsi: fix build errors, SCSI_FC_ATTRS needs to depend on
 SCSI && NET
Date: Mon, 15 Sep 2014 17:20:42 -0700
Message-ID: <5417825A.4050902@infradead.org>
References: <1410813921-24400-1-git-send-email-anish@chelsio.com> <1410813921-24400-2-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, mchan@broadcom.com,
	eddie.wai@broadcom.com, jim.epost@gmail.com
To: Anish Bhatt <anish@chelsio.com>, netdev@vger.kernel.org,
	JBottomley@parallels.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45671 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932787AbaIPAUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 20:20:44 -0400
In-Reply-To: <1410813921-24400-2-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix build errors when CONFIG_SCSI_NETLINK is enabled but
CONFIG_NET is not enabled:

drivers/built-in.o: In function `scsi_nl_rcv_msg':
scsi_netlink.c:(.text+0x1850fa): undefined reference to `netlink_ack'
scsi_netlink.c:(.text+0x185105): undefined reference to `skb_pull'
scsi_netlink.c:(.text+0x18515d): undefined reference to `netlink_capable'
drivers/built-in.o: In function `scsi_netlink_init':
(.text+0x185244): undefined reference to `init_net'
drivers/built-in.o: In function `scsi_netlink_init':
(.text+0x185258): undefined reference to `__netlink_kernel_create'
drivers/built-in.o: In function `scsi_netlink_exit':
(.text+0x185291): undefined reference to `netlink_kernel_release'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/scsi/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Based on Anish's previous SCSI_NETLINK patch.
Sorry about missing this one.

--- lnx-317-rc5.orig/drivers/scsi/Kconfig
+++ lnx-317-rc5/drivers/scsi/Kconfig
@@ -257,7 +257,7 @@ config SCSI_SPI_ATTRS
 
 config SCSI_FC_ATTRS
 	tristate "FiberChannel Transport Attributes"
-	depends on SCSI
+	depends on SCSI && NET
 	select SCSI_NETLINK
 	help
 	  If you wish to export transport-specific information about
