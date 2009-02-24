From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: RE: [PATCH NEXT 1/5] netxen: fix physical port mapping
Date: Tue, 24 Feb 2009 00:13:26 -0800
Message-ID: <9FB481EF4C70734186A21A64437F637C02A10E5607@nxexch.unminc.com>
References: <1235374936-28778-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: Dhananjay Phadke <dhananjay@netxen.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:46444 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752000AbZBXIN3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 03:13:29 -0500
In-Reply-To: <1235374936-28778-1-git-send-email-dhananjay@netxen.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please hold off this 5 patch series. I have two critical bug fixes that take priority and will probably clash the pci probe re-factoring patch.

Thanks,
-Dhananjay
________________________________________
From: Dhananjay Phadke [dhananjay@netxen.com]
Sent: Sunday, February 22, 2009 11:42 PM
To: netdev@vger.kernel.org
Cc: davem@davemloft.net
Subject: [PATCH NEXT 1/5] netxen: fix physical port mapping

The PCI function to physical port mapping is valid only for
old firmware. New firmware (4.0.0+) abstracts this.
So driver should never try to access phy using invalid
mapping.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7401779..f1811ca 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -796,9 +796,12 @@ skip_doorbell:
         * See if the firmware gave us a virtual-physical port mapping.
         */
        adapter->physical_port = adapter->portnum;
-       i = adapter->pci_read_normalize(adapter, CRB_V2P(adapter->portnum));
-       if (i != 0x55555555)
-               adapter->physical_port = i;
+       if (adapter->fw_major < 4) {
+               i = adapter->pci_read_normalize(adapter,
+                               CRB_V2P(adapter->portnum));
+               if (i != 0x55555555)
+                       adapter->physical_port = i;
+       }

        adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);

--
1.6.0.2

