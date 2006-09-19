From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: process tx pause frames.
Date: Tue, 19 Sep 2006 14:13:08 -0700
Message-ID: <20060919141308.7e52b7d0@localhost.localdomain>
References: <20060906124447.642940bd@localhost.localdomain>
	<45056102.2010408@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54185 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751132AbWISVOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:14:50 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45056102.2010408@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch already is in 2.6.17 stable, but the bigger version was pushed
off till 2.6.19. Here is a less intrusive version that needs to go into 2.6.18
(or I'll end up sending it for 2.6.18.1). The driver was telling the
GMAC to flush (not process) pause frames. Manually disabling pause wasn't
working because of problems in the setup.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/drivers/net/sky2.h	2006-07-13 12:50:52.000000000 -0700
+++ linux-2.6/drivers/net/sky2.h	2006-09-19 14:09:21.000000000 -0700
@@ -1566,7 +1566,7 @@
 
 	GMR_FS_ANY_ERR	= GMR_FS_RX_FF_OV | GMR_FS_CRC_ERR |
 			  GMR_FS_FRAGMENT | GMR_FS_LONG_ERR |
-		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC | GMR_FS_GOOD_FC |
+		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC |
 			  GMR_FS_UN_SIZE | GMR_FS_JABBER,
 };
 
