From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6] cdc_ether: Partially revert "usbnet: Set link down
 initially ..."
Date: Thu, 28 Jan 2010 23:18:44 +0000
Message-ID: <1264720725.373.550.camel@localhost>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
	 <omZ8aBZReyD.A.rz.COlSLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, avi.rozen@gmail.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41430 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753820Ab0A1XSu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 18:18:50 -0500
In-Reply-To: <omZ8aBZReyD.A.rz.COlSLB@chimera>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71 ("usbnet: Set link down
initially for drivers that update link state") changed the initial link
state in cdc_ether and other drivers based on the understanding that the
devices they support generate link change interrupts.  However, this is
optional in the CDC Ethernet protocol, and two users have reported in
<http://bugzilla.kernel.org/show_bug.cgi?id=14791> that the link state
for their devices remains down.  Therefore, revert the change in
cdc_ether.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Tested-by: Avi Rozen <avi.rozen@gmail.com>
---
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -419,7 +419,7 @@
 
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
-	.flags =	FLAG_ETHER | FLAG_LINK_INTR,
+	.flags =	FLAG_ETHER,
 	// .check_connect = cdc_check_connect,
 	.bind =		cdc_bind,
 	.unbind =	usbnet_cdc_unbind,

-- 
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyou

