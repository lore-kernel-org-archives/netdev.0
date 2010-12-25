From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 10/15] igbvf: force link checking when mailbox timeout has occurred
Date: Fri, 24 Dec 2010 22:06:09 -0800
Message-ID: <1293257174-15498-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141Ab0LYGHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:07:07 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change forces the link down when a mailbox timeout has occurred.
Previously it was possible for a mailbox timeout to occur but for the
interface to stay up.  The problem with this was that it became possible
for an interface to stay up and miss multiple requests resulting in a
possible issue since the interface will be running in an unknown state.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igbvf/vf.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igbvf/vf.c b/drivers/net/igbvf/vf.c
index 0cc13c6..74486a8 100644
--- a/drivers/net/igbvf/vf.c
+++ b/drivers/net/igbvf/vf.c
@@ -362,8 +362,8 @@ static s32 e1000_check_for_link_vf(struct e1000_hw *hw)
 	 * or a virtual function reset
 	 */
 
-	/* If we were hit with a reset drop the link */
-	if (!mbx->ops.check_for_rst(hw))
+	/* If we were hit with a reset or timeout drop the link */
+	if (!mbx->ops.check_for_rst(hw) || !mbx->timeout)
 		mac->get_link_status = true;
 
 	if (!mac->get_link_status)
-- 
1.7.3.4

