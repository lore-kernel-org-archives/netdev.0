From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH v3 net 3/5] net:ethernet:aquantia: Missing spinlock initialization.
Date: Thu, 23 Mar 2017 14:19:43 +0300
Message-ID: <bf3a7df99a61de2d30717f731cca4ad2461125d1.1490267633.git.pavel.belous@aquantia.com>
References: <cover.1490267633.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0051.outbound.protection.outlook.com ([104.47.34.51]:11640
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754636AbdCWLU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 07:20:26 -0400
In-Reply-To: <cover.1490267633.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Fix for missing initialization aq_ring header.lock spinlock.

Fixes: 018423e90bee ("net: ethernet: aquantia: Add ring support code")

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 0358e607..3a8a4aa 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -101,6 +101,7 @@ int aq_ring_init(struct aq_ring_s *self)
 	self->hw_head = 0;
 	self->sw_head = 0;
 	self->sw_tail = 0;
+	spin_lock_init(&self->header.lock);
 	return 0;
 }
 
-- 
2.7.4
