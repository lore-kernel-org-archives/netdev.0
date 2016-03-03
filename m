From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: [PATCH 0/1] be2net: Don't leak iomapped memory on removal.
Date: Thu,  3 Mar 2016 16:35:48 -0600
Message-ID: <1457044549-10563-1-git-send-email-dougmill@linux.vnet.ibm.com>
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e17.ny.us.ibm.com ([129.33.205.207]:59503 "EHLO
	e17.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757437AbcCCWf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:35:56 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Thu, 3 Mar 2016 17:35:55 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 04B03C90043
	for <netdev@vger.kernel.org>; Thu,  3 Mar 2016 17:35:49 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u23MZqC624117258
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2016 22:35:52 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u23MZpAX027232
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2016 17:35:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The adapter->pcicfg resource is either mapped via pci_iomap() or
derived from adapter->db. During be_remove() this resource was ignored
and so could remain mapped after remove.
    
Add a flag to track whether adapter->pcicfg was mapped or not, then
use that flag in be_unmap_pci_bars() to unmap if required.
    
Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>
