From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 19/26] igb: move get_hw_control within igb_resume.
Date: Sat, 07 Feb 2009 01:21:10 -0800
Message-ID: <20090207092110.15697.6428.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:44136
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755987AbZBGJVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:21:30 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Move igb_get_hw_control up so that it is called just after the reset in
igb_resume.  This notifies the HW sooner that the driver is reassuming
control of the device.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 56c1455..accab3f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4341,6 +4341,11 @@ static int igb_resume(struct pci_dev *pdev)
 	/* e1000_power_up_phy(adapter); */
 
 	igb_reset(adapter);
+
+	/* let the f/w know that the h/w is now under the control of the
+	 * driver. */
+	igb_get_hw_control(adapter);
+
 	wr32(E1000_WUS, ~0);
 
 	if (netif_running(netdev)) {
@@ -4351,10 +4356,6 @@ static int igb_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	/* let the f/w know that the h/w is now under the control of the
-	 * driver. */
-	igb_get_hw_control(adapter);
-
 	return 0;
 }
 #endif

