From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/6] e1000e: Use time_after to account for jiffies wrapping
Date: Fri, 10 Aug 2007 13:00:57 -0700
Message-ID: <20070810200057.21509.18676.stgit@localhost.localdomain>
References: <20070810200038.21509.77815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13994 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938172AbXHJUA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:00:58 -0400
In-Reply-To: <20070810200038.21509.77815.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index d184116..d14cc4b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1411,7 +1411,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 			 * enough time to complete the receives, if it's
 			 * exceeded, break and error off
 			 */
-		} while (good_cnt < 64 && jiffies < (time + 20));
+		} while ((good_cnt < 64) && !time_after(jiffies, time + 20));
 		if (good_cnt != 64) {
 			ret_val = 13; /* ret_val is the same as mis-compare */
 			break;
