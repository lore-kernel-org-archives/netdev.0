From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch netdev-2.6] skge: return 0 on success from SkGeChangeMtu
Date: Thu, 18 Nov 2004 14:14:35 -0500
Message-ID: <20041118141435.B16007@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgoos@syskonnect.de, mlindner@syskonnect.de, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The SKGE driver needs to return 0 from SkGeChangeMtu() on success.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
The proper sucessful return code for the change_mtu() method is zero.
For some reason, SkGeChangeMtu() is returning the new mtu value
instead.  The comments would seem to indicate past problems, but the
current correct behaviour is clear.

 drivers/net/sk98lin/skge.c |   14 +-------------
 1 files changed, 1 insertion(+), 13 deletions(-)

--- 1.54/drivers/net/sk98lin/skge.c	2004-11-03 17:31:05 -05:00
+++ 1.55/drivers/net/sk98lin/skge.c	2004-11-18 11:12:36 -05:00
@@ -2849,19 +2849,7 @@
 	SkEventDispatcher(pAC, pAC->IoBase);
 	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 	
-	/*
-	** While testing this driver with latest kernel 2.5 (2.5.70), it 
-	** seems as if upper layers have a problem to handle a successful
-	** return value of '0'. If such a zero is returned, the complete 
-	** system hangs for several minutes (!), which is in acceptable.
-	**
-	** Currently it is not clear, what the exact reason for this problem
-	** is. The implemented workaround for 2.5 is to return the desired 
-	** new MTU size if all needed changes for the new MTU size where 
-	** performed. In kernels 2.2 and 2.4, a zero value is returned,
-	** which indicates the successful change of the mtu-size.
-	*/
-	return NewMtu;
+	return 0;
 
 } /* SkGeChangeMtu */
 
