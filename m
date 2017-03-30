From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net 0/7] ibmvnic: Cleanup resource handling
Date: Thu, 30 Mar 2017 02:48:49 -0400
Message-ID: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:51948 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753003AbdC3C73 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 22:59:29 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2U2tB6C049373
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:28 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29gcthsyh3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:27 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 29 Mar 2017 22:59:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to better manage the resources of the ibmvnic driver, this set of
patches creates a set of initialization and release routines for the
drivers resources. Additionally, some patches do some re-naming of the
affected routines so that there is a common naming scheme in the driver.

-Nathan

---

Nathan Fontenot (7):
      ibmvnic: Update main crq initialization and release
      ibmvnic: Create init and release routines for the bounce buffer
      ibmvnic: Create init and release routines for the tx pool
      ibmvnic: Create init and release routines for the rx pool
      ibmvnic: Merge the two release_sub_crq_queue routines
      ibmvnic: Create init/release routines for stats token
      ibmvnic: Cleanup failure path in ibmvnic_open


 drivers/net/ethernet/ibm/ibmvnic.c |  556 ++++++++++++++++++++----------------
 1 file changed, 303 insertions(+), 253 deletions(-)
