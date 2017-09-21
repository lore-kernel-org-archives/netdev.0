From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 3/4] net:ethernet:aquantia: Fix transient invalid link down/up indications
Date: Thu, 21 Sep 2017 13:53:41 +0300
Message-ID: <6c8d54cad231f22ba46e08d3ec0fe9d6fcef7468.1505915085.git.igor.russkikh@aquantia.com>
References: <cover.1505915085.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0040.outbound.protection.outlook.com ([104.47.40.40]:63424
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751738AbdIUKyo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 06:54:44 -0400
In-Reply-To: <cover.1505915085.git.igor.russkikh@aquantia.com>
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
index 4f5ec9a..ab5d3cb 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c
@@ -351,8 +351,7 @@ int hw_atl_utils_mpi_get_link_status(struct aq_hw_s *self)
 			break;
 
 		default:
-			link_status->mbps = 0U;
-			break;
+			return -1;
 		}
 	}
 
-- 
2.7.4
