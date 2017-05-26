From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/11] ibmvnic: Driver updates
Date: Fri, 26 May 2017 10:30:07 -0400
Message-ID: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39161 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1762032AbdEZOlx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:41:53 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEdOTJ029452
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:41:52 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2apc2e92x4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:41:52 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:41:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches implements several updates to the ibmvnic driver
to fix issues that have been found in testing. Most of the updates
invovle updating queue handling during driver close and reset
operations.

-Nathan
---

John Allen (4):
      ibmvnic: Track state of adapter napis
      ibmvnic: Handle failover after failed init crq
      ibmvnic: Send gratuitous arp on reset
      ibmvnic: Non-fatal error handling

Nathan Fontenot (4):
      ibmvnic: Check adapter state during ibmvnic_poll
      ibmvnic: Reset the CRQ queue during driver reset
      ibmvnic: Reset tx/rx pools on driver reset
      ibmvnic: Reset sub-crqs during driver reset

Thomas Falcon (3):
      ibmvnic: Fix cleanup of SKB's on driver close
      ibmvnic: Halt TX and report carrier off on H_CLOSED return code
      ibmvnic: Deactivate RX pool buffer replenishment on H_CLOSED


 drivers/net/ethernet/ibm/ibmvnic.c |  259 ++++++++++++++++++++++++++++++------
 drivers/net/ethernet/ibm/ibmvnic.h |    2 
 2 files changed, 220 insertions(+), 41 deletions(-)
