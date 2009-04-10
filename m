From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 10/10] Be explict with what we are !'ing in
	ixgbe_sfp_config_module_task()
Date: Fri, 10 Apr 2009 01:29:10 -0700
Message-ID: <20090410082910.14372.22207.stgit@localhost.localdomain>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Tony Breeds <tony@bakeyournoodle.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:55251
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S938720AbZDJQ5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:57:39 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
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
index 2856486..813c5bc 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3917,7 +3917,7 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
 	}
 	hw->mac.ops.setup_sfp(hw);
 
-	if (!adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK)
+	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
 		/* This will also work for DA Twinax connections */
 		schedule_work(&adapter->multispeed_fiber_task);
 	adapter->flags &= ~IXGBE_FLAG_IN_SFP_MOD_TASK;

