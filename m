From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/6] sky2: dont flush good pause frames
Date: Thu, 15 Feb 2007 16:40:30 -0800
Message-ID: <20070216004141.678148000@linux-foundation.org>
References: <20070216004028.943889000@linux-foundation.org>
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40572 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422930AbXBPAnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 19:43:20 -0500
Content-Disposition: inline; filename=sky2-pause-flush.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't mark pause frames as errors. This problem caused transmitter not
to pause and would effectively take out a gigabit switch because the
it can't handle overrun. 

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- sky2-dev.orig/drivers/net/sky2.h	2007-02-13 15:08:30.000000000 -0800
+++ sky2-dev/drivers/net/sky2.h	2007-02-13 15:12:52.000000000 -0800
@@ -1589,7 +1589,7 @@
 
 	GMR_FS_ANY_ERR	= GMR_FS_RX_FF_OV | GMR_FS_CRC_ERR |
 			  GMR_FS_FRAGMENT | GMR_FS_LONG_ERR |
-		  	  GMR_FS_MII_ERR | GMR_FS_GOOD_FC | GMR_FS_BAD_FC |
+		  	  GMR_FS_MII_ERR | GMR_FS_BAD_FC |
 			  GMR_FS_UN_SIZE | GMR_FS_JABBER,
 };
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

