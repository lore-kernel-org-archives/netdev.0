From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net 3/5] net:ethernet:aquantia: Missing spinlock initialization.
Date: Wed, 22 Mar 2017 20:06:29 +0300
Message-ID: <86abb43bf828eca04da9f39beb2295a23baf530b.1490202165.git.pavel.belous@aquantia.com>
References: <cover.1490202165.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0070.outbound.protection.outlook.com ([104.47.40.70]:62429
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759086AbdCVRHV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 13:07:21 -0400
In-Reply-To: <cover.1490202165.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Fix for missing initialization aq_ring header.lock spinlock.

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
