From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: change logical negate to bitwise
Date: Wed, 02 Jun 2010 16:43:15 -0700
Message-ID: <20100602234314.13472.35872.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Dan Carpenter <error27@gmail.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:55562 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754989Ab0FBXng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 19:43:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

The bitwise negate is intended here.  With the logical negate the
condition is always false.

Signed-off-by: Dan Carpenter <error27@gmail.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 24507f3..57a7e41 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2554,7 +2554,7 @@ static void e1000_init_manageability_pt(struct e1000_adapter *adapter)
 			mdef = er32(MDEF(i));
 
 			/* Ignore filters with anything other than IPMI ports */
-			if (mdef & !(E1000_MDEF_PORT_623 | E1000_MDEF_PORT_664))
+			if (mdef & ~(E1000_MDEF_PORT_623 | E1000_MDEF_PORT_664))
 				continue;
 
 			/* Enable this decision filter in MANC2H */

