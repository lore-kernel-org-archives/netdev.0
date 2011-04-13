From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 10/13] sfc: set ethtool set_phys_id on/off
	cycle frequency to 1/sec
Date: Wed, 13 Apr 2011 12:59:38 -0700
Message-ID: <20110413195938.25901.96213.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18291 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758459Ab1DMUAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 16:00:01 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Physical identification frequency based on how it was done prior to the
introduction of set_phys_id.  Compile tested only.

Also fixed the compile warning re. "mode" may be used uninitialized.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Cc: Steve Hodgson <shodgson@solarflare.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---

 drivers/net/sfc/ethtool.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 644f7c1..5d8468f 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -182,7 +182,7 @@ static int efx_ethtool_phys_id(struct net_device *net_dev,
 			       enum ethtool_phys_id_state state)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	enum efx_led_mode mode;
+	enum efx_led_mode mode = EFX_LED_DEFAULT;
 
 	switch (state) {
 	case ETHTOOL_ID_ON:
@@ -194,8 +194,8 @@ static int efx_ethtool_phys_id(struct net_device *net_dev,
 	case ETHTOOL_ID_INACTIVE:
 		mode = EFX_LED_DEFAULT;
 		break;
-	default:
-		return -EINVAL;
+	case ETHTOOL_ID_ACTIVE:
+		return 1;	/* cycle on/off once per second */
 	}
 
 	efx->type->set_id_led(efx, mode);

