From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: fix WOL register setup for 82599
Date: Thu, 11 Feb 2010 06:14:08 -0800
Message-ID: <20100211141407.25672.80739.stgit@localhost.localdomain>
References: <20100211141319.25672.3041.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:44070 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752381Ab0BKOO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 09:14:26 -0500
In-Reply-To: <20100211141319.25672.3041.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We need to have the WUS register set to all 1's in order for the hardware
to be capable of ever waking up.  Set it here in the ixgbe_probe().

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7b7c848..951b73c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5763,6 +5763,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+	/* Make it possible the adapter to be woken up via WOL */
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_WUS, ~0);
+
 	/*
 	 * If there is a fan on this device and it has failed log the
 	 * failure.

