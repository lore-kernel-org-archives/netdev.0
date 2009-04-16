From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] Be explict with what we are !'ing in
	ixgbe_sfp_config_module_task()
Date: Thu, 16 Apr 2009 16:22:28 -0700
Message-ID: <20090416232225.18637.33348.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	akpm@linux-foundation.org, roel.kluin@gmail.com,
	Tony Breeds <tony@bakeyournoodle.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:56779
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753338AbZDPXWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 19:22:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Breeds <tony@bakeyournoodle.com>

GCC warns:
drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_sfp_config_module_task':
drivers/net/ixgbe/ixgbe_main.c:3920: warning: suggest parantheses around
operand of '!' or change '&' to '&&' or '!' to '~'

Which I think is right.  Bracket to remove ambiguity.

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index febde45..49a9037 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3946,7 +3946,7 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
 	}
 	hw->mac.ops.setup_sfp(hw);
 
-	if (!adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK)
+	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
 		/* This will also work for DA Twinax connections */
 		schedule_work(&adapter->multispeed_fiber_task);
 	adapter->flags &= ~IXGBE_FLAG_IN_SFP_MOD_TASK;

