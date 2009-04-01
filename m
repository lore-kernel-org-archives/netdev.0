From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/5] igb: increase delay for copper link setup
Date: Tue, 31 Mar 2009 23:38:38 -0700
Message-ID: <20090401063837.3046.221.stgit@lost.foo-projects.org>
References: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:50449
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757237AbZDAGi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 02:38:58 -0400
In-Reply-To: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Increase the delay for copper phy init from 15ms to 100ms.  This is to
address issues seen in which ethtool -t was failing in some cases on 82576
based adapters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_phy.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index de2d486..f50fac2 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -448,8 +448,11 @@ s32 igb_copper_link_setup_igp(struct e1000_hw *hw)
 		goto out;
 	}
 
-	/* Wait 15ms for MAC to configure PHY from NVM settings. */
-	msleep(15);
+	/*
+	 * Wait 100ms for MAC to configure PHY from NVM settings, to avoid
+	 * timeout issues when LFS is enabled.
+	 */
+	msleep(100);
 
 	/*
 	 * The NVM settings will configure LPLU in D3 for

