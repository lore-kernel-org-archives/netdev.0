From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/4] igb: check both function bits in status register
	in wol exception
Date: Wed, 23 Dec 2009 15:21:46 -0800
Message-ID: <20091223232145.16146.15465.stgit@localhost.localdomain>
References: <20091223232047.16146.35264.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:43239
	"EHLO QMTA14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754933AbZLWXWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:22:06 -0500
In-Reply-To: <20091223232047.16146.35264.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The ethtool code for enabling Wake on Lan was not correctly checking the
status register bits so as a result ports 0 and 2 were both being allowed
to set WOL to enabled even though it is only supported on the first port
for our adapters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index ac9d527..f771a6c 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1795,7 +1795,7 @@ static int igb_wol_exclusion(struct igb_adapter *adapter,
 		/* dual port cards only support WoL on port A from now on
 		 * unless it was enabled in the eeprom for port B
 		 * so exclude FUNC_1 ports from having WoL enabled */
-		if (rd32(E1000_STATUS) & E1000_STATUS_FUNC_1 &&
+		if ((rd32(E1000_STATUS) & E1000_STATUS_FUNC_MASK) &&
 		    !adapter->eeprom_wol) {
 			wol->supported = 0;
 			break;

