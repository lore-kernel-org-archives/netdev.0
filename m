From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/6] igb: reduce size required to trigger low latency
Date: Thu, 12 Feb 2009 20:17:21 -0800
Message-ID: <20090213041721.3848.61896.stgit@lost.foo-projects.org>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:42601 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757865AbZBMERl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 23:17:41 -0500
In-Reply-To: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Update the Adaptive Interrupt Moderation algorithm so that the low latency
state is triggered less easily to prevent high interrupt loads.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1e7678c..8701330 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2541,7 +2541,7 @@ static unsigned int igb_update_itr(struct igb_adapter *adapter, u16 itr_setting,
 		if (bytes > 25000) {
 			if (packets > 35)
 				retval = low_latency;
-		} else if (bytes < 6000) {
+		} else if (bytes < 1500) {
 			retval = low_latency;
 		}
 		break;

