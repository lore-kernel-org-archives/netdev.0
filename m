From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: add check for fiber/serdes devices to
	igb_set_spd_dplx;
Date: Wed, 13 Oct 2010 01:27:02 -0700
Message-ID: <20101013082611.24740.80297.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:60988 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753133Ab0JMI1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 04:27:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 55edcb7..5b04eff 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -6115,6 +6115,13 @@ int igb_set_spd_dplx(struct igb_adapter *adapter, u16 spddplx)
 
 	mac->autoneg = 0;
 
+	/* Fiber NIC's only allow 1000 Gbps Full duplex */
+	if ((adapter->hw.phy.media_type == e1000_media_type_internal_serdes) &&
+		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
+		dev_err(&pdev->dev, "Unsupported Speed/Duplex configuration\n");
+		return -EINVAL;
+	}
+
 	switch (spddplx) {
 	case SPEED_10 + DUPLEX_HALF:
 		mac->forced_speed_duplex = ADVERTISE_10_HALF;

