From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2.6.25] igb: fix legacy mode irq issue
Date: Wed, 13 Feb 2008 22:19:20 -0500
Message-ID: <20080214031920.GI856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752390AbYBNDTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 22:19:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I booted an igb kernel with the option pci=nomsi and instantly noticed
that interrupts no longer worked on my igb device.  I took a look at the
interrupt initialization and quickly discovered a comment stating:

"DO NOT USE EIAME or IAME in legacy mode"

It seemed a bit odd that bits to enable IAM were being set in legacy
interrupt mode, so I dropped out the following parts and interrupts
began working fine again.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 igb_main.c |    3 ---
 1 files changed, 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f3c144d..be5da09 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -472,9 +471,6 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		goto request_done;
 	}
 
-	/* enable IAM, auto-mask */
-	wr32(E1000_IAM, IMS_ENABLE_MASK);
-
 request_done:
 	return err;
 }
