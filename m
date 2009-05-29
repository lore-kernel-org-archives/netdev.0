From: Mike Mason <mmlnx@us.ibm.com>
Subject: [PATCH] e1000e: io_error_detected callback should return PCI_ERS_RESULT_DISCONNECT
 on permanent failure
Date: Fri, 29 May 2009 14:16:40 -0700
Message-ID: <4A2050B8.7050302@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:35780 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbZE2VQl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 17:16:41 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4TL53SD008328
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 17:05:03 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4TLGg4U256262
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 17:16:42 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4TLGgpO029641
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 17:16:42 -0400
Received: from [127.0.0.1] ([9.57.84.243])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id n4TLGepc029580
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 17:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI drivers that implement the io_error_detected callback
should return PCI_ERS_RESULT_DISCONNECT if the state
passed in is pci_channel_io_perm_failure.  This state is 
not checked in many of the network drivers.

This patch fixes the omission in the e1000e driver.

Signed-off-by: Mike Mason <mmlnx@us.ibm.com> 

--- a/drivers/net/e1000e/netdev.c	2009-05-23 14:47:00.000000000 -0700
+++ b/drivers/net/e1000e/netdev.c	2009-05-29 13:43:24.000000000 -0700
@@ -4616,6 +4616,9 @@ static pci_ers_result_t e1000_io_error_d
 
 	netif_device_detach(netdev);
 
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	if (netif_running(netdev))
 		e1000e_down(adapter);
 	pci_disable_device(pdev);

