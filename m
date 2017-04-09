From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/7] ibmvnic: Assorted driver updates
Date: Sun, 09 Apr 2017 00:11:27 -0400
Message-ID: <20170409040328.47642.33535.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, muvic@linux.vnet.ibm.com
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45390 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751125AbdDIEWS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 00:22:18 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v394Ikt3004922
        for <netdev@vger.kernel.org>; Sun, 9 Apr 2017 00:22:17 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29pv0gmwmp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 09 Apr 2017 00:22:17 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sun, 9 Apr 2017 00:22:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a set of updates to the ibmvnic driver to fix severalbugs in the
ibmvnic driver.

Patch 1/7: Add is_up flag to avoid sending packets when drivern is down
Patch 2/7: Report errors releasing sub-crqs
Patch 3/7: Correct change_mac_addr struct format
Patch 4/7: Unmap long term buffers before free'ing them
Patch 5/7: Fix up atomic API usage
Patch 6/7: Don't disable irq after scheduling tasklet
Patch 7/7: Remove inflight tracker

-Nathan
---

Nathan Fontenot (1):
      ibmvnic: Remove inflight list

Thomas Falcon (2):
      ibmvnic: Add is_up flag to avoid transmits when driver is down
      ibmvnic: Report errors when failing to release sub-crqs

Brian King (3):
      ibmvnic: Unmap longer term buffer before free
      ibmvnic: Fixup atomic API usage
      ibmvnic: Do not disable IRQ after scheduling tasklet

Murilo Fossa Vicentini (1):
      ibmvnic: Fix ibmvnic_change_mac_addr struct format

 drivers/net/ethernet/ibm/ibmvnic.c |  162 +++++++++++-------------------------
 drivers/net/ethernet/ibm/ibmvnic.h |   12 ---
 2 files changed, 51 insertions(+), 123 deletions(-)
