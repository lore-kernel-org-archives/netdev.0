From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 0/5 net-next v2] ibmvnic: LPM bug fixes
Date: Wed, 14 Jun 2017 23:50:04 -0500
Message-ID: <1497502209-16248-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        davem@davemloft.net, Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:41916 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750774AbdFOEud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 00:50:33 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F4mcj3031144
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 00:50:32 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b3k3ds19u-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 00:50:32 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 15 Jun 2017 00:50:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of small patches is meant to resolve a number of
bugs, mostly occurring during an ibmvnic driver reset when
recovering from a logical partition migration (LPM).

The first patch ensures that RX buffer pools are properly
activated following an adapter reset by setting the proper
flag in the pool data structure.

The second patch uses netif_tx_disable to stop TX queues when
closing the device during a reset.

Third, fixup a typo that resulted in partial sanitization of
TX/RX descriptor queues following a device reset.

Fourth, remove an ambiguous conditional check that was resulting
in a kernel panic as null RX/TX completion descriptors were being
processed during napi polling while the device is closing.

Finally, fix a condition where the napi polling routine exits
before it has completed its work budget without notifying the
upper network layers. This omission could result in the
napi_disable function sleeping indefinitely under certain conditions.

v2: Attempt to provide a proper cover letter

Thomas Falcon (5):
  ibmvnic: Activate disabled RX buffer pools on reset
  ibmvnic: Ensure that TX queues are disabled in __ibmvnic_close
  ibmvnic: Sanitize entire SCRQ buffer on reset
  ibmvnic: Remove VNIC_CLOSING check from pending_scrq
  ibmvnic: Exit polling routine correctly during adapter reset

 drivers/net/ethernet/ibm/ibmvnic.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

-- 
1.8.3.1
