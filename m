From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/4] igb: correctly offset 82575 flow control
	watermarks by 16 bytes
Date: Wed, 23 Dec 2009 15:21:27 -0800
Message-ID: <20091223232126.16146.13862.stgit@localhost.localdomain>
References: <20091223232047.16146.35264.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:37889
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755394AbZLWXVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:21:45 -0500
In-Reply-To: <20091223232047.16146.35264.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The watermark values for the 82575 were not being set correctly.  As a
result the high and low watermark values were set to the same value which
can lead to excess xon/xoff packets being generated.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 78963a0..933c64f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1306,13 +1306,8 @@ void igb_reset(struct igb_adapter *adapter)
 	hwm = min(((pba << 10) * 9 / 10),
 			((pba << 10) - 2 * adapter->max_frame_size));
 
-	if (mac->type < e1000_82576) {
-		fc->high_water = hwm & 0xFFF8;	/* 8-byte granularity */
-		fc->low_water = fc->high_water - 8;
-	} else {
-		fc->high_water = hwm & 0xFFF0;	/* 16-byte granularity */
-		fc->low_water = fc->high_water - 16;
-	}
+	fc->high_water = hwm & 0xFFF0;	/* 16-byte granularity */
+	fc->low_water = fc->high_water - 16;
 	fc->pause_time = 0xFFFF;
 	fc->send_xon = 1;
 	fc->current_mode = fc->requested_mode;

