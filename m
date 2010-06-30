From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/4] e1000e: disable EEE support by default
Date: Tue, 29 Jun 2010 21:13:13 -0700
Message-ID: <20100630041311.8652.42432.stgit@localhost.localdomain>
References: <20100630040959.8652.31147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bhutchings@solarflare.com, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:45241 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751115Ab0F3ENe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 00:13:34 -0400
In-Reply-To: <20100630040959.8652.31147.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Based on community feedback, EEE should be disabled by default until the
IEEE802.3az specification has been finalized.

Cc: bhutchings@solarflare.com
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 6b5e108..63930d1 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -731,6 +731,10 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	    (adapter->hw.phy.type == e1000_phy_igp_3))
 		adapter->flags |= FLAG_LSC_GIG_SPEED_DROP;
 
+	/* Disable EEE by default until IEEE802.3az spec is finalized */
+	if (adapter->flags2 & FLAG2_HAS_EEE)
+		adapter->hw.dev_spec.ich8lan.eee_disable = true;
+
 	return 0;
 }
 

