From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/11] ibmvnic: Updated reset handler and code fixes
Date: Sat, 29 Apr 2017 04:15:27 -0400
Message-ID: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46106 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752619AbdD2E0l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 00:26:41 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3T4ONGG107911
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:26:40 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a4h5u4bwu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:26:40 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sat, 29 Apr 2017 00:26:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches multiple code fixes and a new rest handler
for the ibmvnic driver. In order to implement the new reset handler
for the ibmvnic driver resource initialization needed to be moved to
its own routine, a state variable is introduced to replace the
various is_* flags in the driver, and a new routine to handle the
assorted reasons the driver can be reset.

The additional patches cleanup some of the code, renmove some
memory leaks, and fix a few bugs.

---

Nathan Fontenot (10):
      ibmvnic: Move resource initialization to its own routine
      ibmvnic: Replace is_closed with state field
      ibmvnic: Updated reset handling
      ibmvnic: Delete napi's when releasing driver resources
      ibmvnic: Whitespace correction in release_rx_pools
      ibmvnic: Clean up tx pools when closing
      ibmvnic: Wait for any pending scrqs entries at driver close
      ibmvnic: Check for driver reset first in ibmvnic_xmit
      ibmvnic: Continue skb processing after skb completion error
      ibmvnic: Move queue restart

Thomas Falcon (1):
      From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>


 drivers/net/ethernet/ibm/ibmvnic.c |  564 +++++++++++++++++++++++-------------
 drivers/net/ethernet/ibm/ibmvnic.h |   31 ++
 2 files changed, 390 insertions(+), 205 deletions(-)
