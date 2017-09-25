From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net v2 3/4] net:ethernet:aquantia: Fix transient invalid link down/up indications
Date: Mon, 25 Sep 2017 10:48:49 +0300
Message-ID: <c2f8c1e781fdeb8a6951c927808d5adb906c7d2f.1506324091.git.igor.russkikh@aquantia.com>
References: <cover.1506324091.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0068.outbound.protection.outlook.com ([104.47.34.68]:26976
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933208AbdIYHtl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 03:49:41 -0400
In-Reply-To: <cover.1506324091.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to a bug in aquantia atlantic card firmware, it sometimes reports
invalid link speed bits. That caused driver to report link down events,
although link itself is totally fine.

This patch ignores such out of blue readings.

Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
index 4f5ec9a..bf734b3 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
@@ -351,8 +351,7 @@ int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self)
 			break;
 
 		default:
-			link_status->mbps = 0U;
-			break;
+			return -EBUSY;
 		}
 	}
 
-- 
2.7.4
