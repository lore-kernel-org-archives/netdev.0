From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] e1000e: Reset 82577/82578 PHY before first
	PHY register read
Date: Thu, 06 May 2010 01:00:27 -0700
Message-ID: <20100506080025.8910.45557.stgit@localhost.localdomain>
References: <20100506075959.8910.13493.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:50401
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753055Ab0EFIAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:00:45 -0400
In-Reply-To: <20100506075959.8910.13493.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Reset the PHY before first accessing it.  Doing so, ensure that the PHY is
in a known good state before we read/write PHY registers. This fixes a
driver probe failure.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 0bfef8e..b8c4dce 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -294,6 +294,16 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 		msleep(50);
 	}
 
+	/*
+	 * Reset the PHY before any acccess to it.  Doing so, ensures that
+	 * the PHY is in a known good state before we read/write PHY registers.
+	 * The generic reset is sufficient here, because we haven't determined
+	 * the PHY type yet.
+	 */
+	ret_val = e1000e_phy_hw_reset_generic(hw);
+	if (ret_val)
+		goto out;
+
 	phy->id = e1000_phy_unknown;
 	ret_val = e1000e_get_phy_id(hw);
 	if (ret_val)

