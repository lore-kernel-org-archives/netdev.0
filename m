From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] snap: handle registration error and compile warning
Date: Fri, 20 Feb 2009 10:03:02 -0800
Message-ID: <20090220100302.561dcfab@extreme>
References: <20090220100206.533d59d4@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45522 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311AbZBTSDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2009 13:03:09 -0500
In-Reply-To: <20090220100206.533d59d4@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If this module can't load, it is almost certainly because something else
is already bound to that SAP. So in that case, return the same error code
as other SAP usage, and fail the module load.

Also fixes a compiler warning about printk of non const.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/802/psnap.c	2009-02-20 08:38:04.545372306 -0800
+++ b/net/802/psnap.c	2009-02-20 08:39:16.394961522 -0800
@@ -95,15 +95,16 @@ static int snap_request(struct datalink_
 EXPORT_SYMBOL(register_snap_client);
 EXPORT_SYMBOL(unregister_snap_client);
 
-static char snap_err_msg[] __initdata =
+static const char snap_err_msg[] __initconst =
 	KERN_CRIT "SNAP - unable to register with 802.2\n";
 
 static int __init snap_init(void)
 {
 	snap_sap = llc_sap_open(0xAA, snap_rcv);
-
-	if (!snap_sap)
+	if (!snap_sap) {
 		printk(snap_err_msg);
+		return -EBUSY;
+	}
 
 	return 0;
 }
