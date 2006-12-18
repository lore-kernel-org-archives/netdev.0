From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2/8] NetXen: driver reload fix for newer firmware.
Date: Mon, 18 Dec 2006 05:51:29 -0800
Message-ID: <200612181351.kBIDpTJc012150@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:4198 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754063AbWLROWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 09:22:53 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

netxen_nic_main.c |    7 +++++++
 1 files changed, 7 insertions(+)


diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index d8b1daf..f2b3fbc 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -446,6 +446,11 @@ netxen_nic_probe(struct pci_dev *pdev, c
 		adapter->port[i] = port;
 	}
 
+	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+	netxen_pinit_from_rom(adapter, 0);
+	udelay(500);
+	netxen_load_firmware(adapter);
+	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	/*
 	 * delay a while to ensure that the Pegs are up & running.
 	 * Otherwise, we might see some flaky behaviour.
@@ -533,6 +538,8 @@ static void __devexit netxen_nic_remove(
 
 	netxen_nic_stop_all_ports(adapter);
 	/* leave the hw in the same state as reboot */
+	netxen_pinit_from_rom(adapter, 0);
+	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 	netxen_load_firmware(adapter);
 	netxen_free_adapter_offload(adapter);
 
