From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 05/29] ixgbe: link change interrupt was not
	causing link event
Date: Thu, 11 Sep 2008 19:55:58 -0700
Message-ID: <20080912025536.6234.77977.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:19750 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbYILC4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:56:01 -0400
Received: by rv-out-0506.google.com with SMTP id k40so612307rvb.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:56:00 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Upon review a buglet was found where link change was not causing
an immediate link change event as it should.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 036393e..11bf86b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -758,9 +758,9 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 	ixgbe_set_ivar(adapter, IXGBE_IVAR_OTHER_CAUSES_INDEX, v_idx);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx), 1950);
 
-	/* set up to autoclear timer, lsc, and the vectors */
+	/* set up to autoclear timer, and the vectors */
 	mask = IXGBE_EIMS_ENABLE_MASK;
-	mask &= ~IXGBE_EIMS_OTHER;
+	mask &= ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC, mask);
 }
 

