From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH 1/1 net-2.6] s2io: enabling VLAN tag stripping at driver initialization
Date: Thu, 04 Sep 2008 14:46:03 -0300
Message-ID: <48C01EDB.7020001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Jay Vosburgh <fubar@us.ibm.com>,
	netdev <netdev@vger.kernel.org>, Lorandi <rafaello@br.ibm.com>
To: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:46551 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755722AbYIDRql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 13:46:41 -0400
Received: from mailhub3.br.ibm.com (unknown [9.18.232.110])
	by igw3.br.ibm.com (Postfix) with ESMTP id 017FD390236
	for <netdev@vger.kernel.org>; Thu,  4 Sep 2008 14:25:45 -0300 (BRST)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m84HkALj4305004
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 14:46:16 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m84Hk2M6013629
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 14:46:03 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually s2io has a bug in VLAN support. VLAN doesn't work except if
you'd opened the interface in promiscuous mode before. 
This happens because VLAN tag stripping is not enable by default (when
the device is loaded). It is only enabled when the device leaves
promiscuous mode.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a2b0730..e656c80 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8206,6 +8206,14 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	/* Initialize device name */
 	sprintf(sp->name, "%s Neterion %s", dev->name, sp->product_name);
 
+	/* Initialize VLAN tag strip */
+	if (vlan_tag_strip) {
+		val64 = readq(&bar0->rx_pa_cfg);
+		val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
+		writeq(val64, &bar0->rx_pa_cfg);
+		vlan_strip_flag = 1;
+	}
+
 	/*
 	 * Make Link state as off at this point, when the Link change
 	 * interrupt comes the state will be automatically changed to
