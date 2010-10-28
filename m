From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: Add check for reset flags before displaying
	reset message
Date: Thu, 28 Oct 2010 03:59:55 -0700
Message-ID: <20101028105955.27748.92516.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:36660
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757951Ab0J1K75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 06:59:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Some parts need to execute resets during normal operation.  This flag
check ensures that those parts reset without needlessly alarming the
user.  Other unexpected resets by other parts will dump debug info
and message the reset action to the user, as originally intended.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 35a9dd4..c4ca162 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4882,8 +4882,11 @@ static void e1000_reset_task(struct work_struct *work)
 	struct e1000_adapter *adapter;
 	adapter = container_of(work, struct e1000_adapter, reset_task);
 
-	e1000e_dump(adapter);
-	e_err("Reset adapter\n");
+	if (!((adapter->flags & FLAG_RX_NEEDS_RESTART) &&
+	      (adapter->flags & FLAG_RX_RESTART_NOW))) {
+		e1000e_dump(adapter);
+		e_err("Reset adapter\n");
+	}
 	e1000e_reinit_locked(adapter);
 }
 

