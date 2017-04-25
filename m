From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/2] Move sub crq init out of interrupt context
Date: Tue, 25 Apr 2017 15:00:58 -0400
Message-ID: <20170425185704.41126.65738.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38473 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1949064AbdDYPMJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:12:09 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PF9LHA146591
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:12:07 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a26s4xrcj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:12:07 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 25 Apr 2017 11:12:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sub crqs are currently intialized in interrupt context when
handling a crq response fromn the vios server. There is no reason
they must be initialized there.

Moving the initialization of the sub crqs to the ibmvnic_init routine
allows us to do the initialization outside of interrupt context and
make all of the allocations with GFP_KERNEL instead of GFP_ATOMIC.

-Nathan

---

Nathan Fontenot (2):
      ibmvnic: Split initialization of scrqs to its own routine
      ibmvnic: Move initialization of sub crqs to ibmvnic_init


 drivers/net/ethernet/ibm/ibmvnic.c |  114 +++++++++++++++++++-----------------
 1 file changed, 61 insertions(+), 53 deletions(-)
