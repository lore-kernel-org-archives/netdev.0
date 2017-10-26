From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH v3 net-next 0/2] ibmvnic: Tunable parameter support
Date: Thu, 26 Oct 2017 16:22:19 -0500
Message-ID: <7a1711ef-a7d6-1eea-90e7-c5c655742cba@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:43950 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751305AbdJZVW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 17:22:28 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9QLKuCt125806
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 17:22:28 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dumpufudg-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 17:22:27 -0400
Received: from localhost
        by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Thu, 26 Oct 2017 15:22:27 -0600
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements support for changing tunable parameters such as the
mtu, number of tx/rx queues, and number of buffers per queue via ethtool
and ifconfig.

v2: -Fix conflict with Tom's recently applied TSO/SG patches
v3: -Initialize rc in __ibmvnic_reset fixing build warning
    -Fix buggy behavior with pending mac changes. Use boolean flag
     to track if mac change is needed on open rather than relying on
     the desired->mac pointer.
    -Directly include tunable structs in the adapter struct rather
     than keeping pointers, eliminating the need to directly allocate
     them.

John Allen (2):
  ibmvnic: Update reset infrastructure to support tunable parameters
  ibmvnic: Fix failover error path for non-fatal resets

 drivers/net/ethernet/ibm/ibmvnic.c | 217 ++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/ibm/ibmvnic.h |  26 ++++-
 2 files changed, 213 insertions(+), 30 deletions(-)

-- 
1.8.3.1
