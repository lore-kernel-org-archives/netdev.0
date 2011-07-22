From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] e1000: always call e1000_check_for_link() on e1000_ce4100 MACs.
Date: Thu, 21 Jul 2011 23:09:02 -0700
Message-ID: <1311314951-11142-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Nicolas Schichan <nschichan@freebox.fr>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288Ab1GVGJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 02:09:15 -0400
In-Reply-To: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Schichan <nschichan@freebox.fr>

Interrupts about link lost or rx sequence errors are not reported by
the ce4100 hardware, leading to transitions from link UP to link DOWN
never being reported.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index acaebec..f97afda 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2402,13 +2402,16 @@ bool e1000_has_link(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	bool link_active = false;
 
-	/* get_link_status is set on LSC (link status) interrupt or
-	 * rx sequence error interrupt.  get_link_status will stay
-	 * false until the e1000_check_for_link establishes link
-	 * for copper adapters ONLY
+	/* get_link_status is set on LSC (link status) interrupt or rx
+	 * sequence error interrupt (except on intel ce4100).
+	 * get_link_status will stay false until the
+	 * e1000_check_for_link establishes link for copper adapters
+	 * ONLY
 	 */
 	switch (hw->media_type) {
 	case e1000_media_type_copper:
+		if (hw->mac_type == e1000_ce4100)
+			hw->get_link_status = 1;
 		if (hw->get_link_status) {
 			e1000_check_for_link(hw);
 			link_active = !hw->get_link_status;
-- 
1.7.6

