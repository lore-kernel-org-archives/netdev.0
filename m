From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/6] e1000e: add Tx timeout factor for 100Mbps
Date: Thu, 19 Nov 2009 14:35:26 -0800
Message-ID: <20091119223526.29164.42989.stgit@localhost.localdomain>
References: <20091119223406.29164.22513.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:38481
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752284AbZKSWfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 17:35:38 -0500
In-Reply-To: <20091119223406.29164.22513.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On some devices (e.g. 82578) not having a Tx timeout factor when linked at
100Mbps can cause false reports of hardware hangs on busy hubs.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a1a5a6f..6345827 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3627,7 +3627,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			case SPEED_100:
 				txb2b = 0;
 				netdev->tx_queue_len = 100;
-				/* maybe add some timeout factor ? */
+				adapter->tx_timeout_factor = 10;
 				break;
 			}
 

