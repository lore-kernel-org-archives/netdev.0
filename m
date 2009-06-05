From: Andre Detsch <adetsch@br.ibm.com>
Subject: [PATCH] e1000: return PCI_ERS_RESULT_DISCONNECT on permanent error
Date: Fri, 5 Jun 2009 15:40:56 -0300
Message-ID: <200906051540.56392.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mmlnx@us.ibm.com
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:55017 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbZFESl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 14:41:27 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.13.1/8.13.1) with ESMTP id n55J89rT005932
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 16:08:09 -0300
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n55Jecub3948672
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 16:40:40 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n55IfOW8027705
	for <netdev@vger.kernel.org>; Fri, 5 Jun 2009 15:41:24 -0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI drivers that implement the io_error_detected callback
should return PCI_ERS_RESULT_DISCONNECT if the state
passed in is pci_channel_io_perm_failure.  This state is
not checked in many of the network drivers.

This patch fixes the omission in the e1000 driver.

Based on Mike Mason's similar patch for e1000e.

Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
Cc: Mike Mason <mmlnx@us.ibm.com>
---
 drivers/net/e1000/e1000_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 05e87a5..df1d5ca 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4816,6 +4816,9 @@ static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
+	
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
 
 	if (netif_running(netdev))
 		e1000_down(adapter);
-- 
1.6.0.2

