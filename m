From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 09/18] igb: cap interrupts at 20K per queue when
	in itr mode 3
Date: Wed, 17 Feb 2010 03:03:19 -0800
Message-ID: <20100217110317.17723.7586.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:58932
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754376Ab0BQLDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:03:36 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

In order to maintain similar performance between MSI-X and
legacy/MSI interrupts, this patch reduces the number of interrupts
when receiving small packets to 20K when in interrupt throttle
rate mode 3.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index eb48e1a..4ccc7fc 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3260,6 +3260,10 @@ static void igb_update_ring_itr(struct igb_q_vector *q_vector)
 	else
 		new_val = avg_wire_size / 2;
 
+	/* when in itr mode 3 do not exceed 20K ints/sec */
+	if (adapter->rx_itr_setting == 3 && new_val < 196)
+		new_val = 196;
+
 set_itr_val:
 	if (new_val != q_vector->itr_val) {
 		q_vector->itr_val = new_val;

