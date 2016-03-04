From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: [PATCH V2 0/1] be2net: Don't leak iomapped memory on removal.
Date: Fri,  4 Mar 2016 15:36:55 -0600
Message-ID: <1457127416-21144-1-git-send-email-dougmill@linux.vnet.ibm.com>
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:38416 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759531AbcCDVhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 16:37:03 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Fri, 4 Mar 2016 14:37:02 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A78D53E4004E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 14:36:59 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u24LaxNo41680918
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2016 14:36:59 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u24LawF3023849
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2016 14:36:59 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The adapter->pcicfg resource is either mapped via pci_iomap() or
derived from adapter->db. During be_remove() this resource was ignored
and so could remain mapped after remove.
    
Add a flag to track whether adapter->pcicfg was mapped or not, then
use that flag in be_unmap_pci_bars() to unmap if required.
    
Fixes: 25848c901 ("use PCI MMIO read instead of config read for errors")
    
Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>
