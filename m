From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: [PATCH 0/1] Fix bug where remove of device fails to free all resources.
Date: Tue,  1 Mar 2016 14:34:51 -0600
Message-ID: <1456864492-32257-1-git-send-email-dougmill@linux.vnet.ibm.com>
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43370 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcCAUe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:34:59 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Tue, 1 Mar 2016 13:34:58 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 8B9E61FF001F
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2016 13:23:05 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u21KYuGG37683356
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 13:34:56 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u21KYtM9021449
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 13:34:55 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    The adapter->pcicfg resource is either mapped via pci_iomap() or
    derived from adapter->db. During be_remove() this resource was ignored
    and so could remain mapped after remove.
    
    Add a flag to track whether adapter->pcicfg was mapped or not, then
    use that flag in be_unmap_pci_bars() to unmap if required.
    
    Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>
