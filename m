From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 21/23] igb: limit minimum mtu to 68 to keep ip
	bound to interface
Date: Wed, 28 Oct 2009 02:52:13 -0700
Message-ID: <20091028095212.13156.22570.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:54147
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752711AbZJ1Jz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:55:56 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Limit the minimum mtu to 68 in order to prevent ip from being unbound from
the interface.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 264ff00..846e64f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3709,8 +3709,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 	u32 rx_buffer_len, i;
 
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
-	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
+	if ((new_mtu < 68) || (max_frame > MAX_JUMBO_FRAME_SIZE)) {
 		dev_err(&pdev->dev, "Invalid MTU setting\n");
 		return -EINVAL;
 	}

