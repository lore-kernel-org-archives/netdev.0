From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] netxen: do_rom_fast_write error handling
Date: Mon, 26 Feb 2007 14:51:56 -0800
Message-ID: <20070226145156.5c0424a3@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Amit S. Kale" <amitkale@netxen.com>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36904 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161303AbXBZWwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 17:52:04 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compiler warning spots real error!

The function do_rom_fast_read called in do_rom_fast_write can fail
and leave data1 unset. This causes a compile warning.  
The correct thing is to propagate the error out.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/netxen/netxen_nic_init.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- pktgen.orig/drivers/net/netxen/netxen_nic_init.c	2007-02-26 14:45:46.000000000 -0800
+++ pktgen/drivers/net/netxen/netxen_nic_init.c	2007-02-26 14:46:37.000000000 -0800
@@ -499,7 +499,10 @@
 		while(1) {
 			int data1;
 
-			do_rom_fast_read(adapter, addridx, &data1);
+			ret = do_rom_fast_read(adapter, addridx, &data1);
+			if (ret < 0)
+				return ret;
+
 			if (data1 == data)
 				break;
 
