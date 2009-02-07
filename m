From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 20/26] igb: change pba size determination from if to
	switch statement
Date: Sat, 07 Feb 2009 01:21:31 -0800
Message-ID: <20090207092131.15697.65672.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:44623
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753678AbZBGJVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:21:51 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

As additional hardware is added to the igb driver it is easier to support
the expansion via switch statements instead of using nested ifs.  For
this reason I am changing this to a switch statement.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index accab3f..d27e502 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -888,11 +888,14 @@ void igb_reset(struct igb_adapter *adapter)
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
 	 */
-	if (mac->type != e1000_82576) {
-	pba = E1000_PBA_34K;
-	}
-	else {
+	switch (mac->type) {
+	case e1000_82576:
 		pba = E1000_PBA_64K;
+		break;
+	case e1000_82575:
+	default:
+		pba = E1000_PBA_34K;
+		break;
 	}
 
 	if ((adapter->max_frame_size > ETH_FRAME_LEN + ETH_FCS_LEN) &&

