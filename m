From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: Do not attempt to perform interrupts in
	netpoll when down
Date: Wed, 13 Jan 2010 03:49:13 -0800
Message-ID: <20100113114847.23119.36954.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:54102
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750978Ab0AMLtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 06:49:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch resolves issues seen when running netconsole and rebooting via
reboot -f.  The issue was due to the fact that we were attempting to
perform interrupt actions when the q_vectors and rings had already been
freed via the ixgbe_shutdown routines.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2ad754c..3859767 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5576,6 +5576,10 @@ static void ixgbe_netpoll(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int i;
 
+	/* if interface is down do nothing */
+	if (test_bit(__IXGBE_DOWN, &adapter->state))
+		return;
+
 	adapter->flags |= IXGBE_FLAG_IN_NETPOLL;
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		int num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;

