From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 4/4] igbvf: Make error message more enlightening
Date: Tue, 17 Nov 2009 13:51:24 -0800
Message-ID: <20091117215123.15119.2904.stgit@localhost.localdomain>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:51730
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753280AbZKQVvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 16:51:37 -0500
In-Reply-To: <20091117214923.15119.98918.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

The most likely cause of this error is that the PF interface is not up,
so let's make that very explicit.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index fad7f34..a3c706c 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2720,7 +2720,8 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
 		dev_info(&pdev->dev,
-		         "PF still in reset state, assigning new address\n");
+			 "PF still in reset state, assigning new address. "
+			 "Is the PF interface up?\n");
 		random_ether_addr(hw->mac.addr);
 	} else {
 		err = hw->mac.ops.read_mac_addr(hw);

