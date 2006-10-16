From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] sky2: don't process pause frames in recveiver.
Date: Mon, 16 Oct 2006 13:52:17 -0700
Message-ID: <20061016135217.5526382b@freekitty>
References: <20061011212225.941046083@osdl.org>
	<20061011212311.715010657@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17573 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161137AbWJPWKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 18:10:53 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061011212311.715010657@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts earlier change that attempted to fix flow control; but was
broken.

Device needs to discard pause frames at the receive DMA engine, otherwise
the pause frames get received and passed up the stack!

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 drivers/net/sky2.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2.orig/drivers/net/sky2.h	2006-10-16 09:44:46.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-10-16 09:50:07.000000000 -0700
@@ -1576,7 +1576,7 @@
 
 	GMR_FS_ANY_ERR	= GMR_FS_RX_FF_OV | GMR_FS_CRC_ERR |
 			  GMR_FS_FRAGMENT | GMR_FS_LONG_ERR |
-		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC |
+		  	  GMR_FS_MII_ERR | GMR_FS_GOOD_FC | GMR_FS_BAD_FC |
 			  GMR_FS_UN_SIZE | GMR_FS_JABBER,
 };
 
