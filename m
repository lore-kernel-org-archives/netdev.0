From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] igb: make certain to power on optics for 82576 fiber nics
Date: Wed, 21 Jan 2009 00:33:48 -0800
Message-ID: <20090121083348.538.52922.stgit@lost.foo-projects.org>
References: <20090121083329.538.67223.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:46756
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759029AbZAUIeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 03:34:07 -0500
In-Reply-To: <20090121083329.538.67223.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It appears that a step was missed in the initialization of 82576 fiber nics
that resulted in it not powering on the optics.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f5e2e72..9b367ba 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1103,6 +1103,13 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 	       E1000_CTRL_SWDPIN1;
 	wr32(E1000_CTRL, reg);
 
+	/* Power on phy for 82576 fiber adapters */
+	if (hw->mac.type == e1000_82576) {
+		reg = rd32(E1000_CTRL_EXT);
+		reg &= ~E1000_CTRL_EXT_SDP7_DATA;
+		wr32(E1000_CTRL_EXT, reg);
+	}
+
 	/* Set switch control to serdes energy detect */
 	reg = rd32(E1000_CONNSW);
 	reg |= E1000_CONNSW_ENRGSRC;

