From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/11] From: Thomas Falcon
 <tlfalcon@linux.vnet.ibm.com>
Date: Sat, 29 Apr 2017 04:16:29 -0400
Message-ID: <20170429081628.13438.83409.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56134 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753818AbdD2E1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 00:27:42 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3T4OKa0119647
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:27:42 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a45ttg9w8-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:27:42 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sat, 29 Apr 2017 00:27:41 -0400
In-Reply-To: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

ibmvnic: Record SKB RX queue during poll

Map each RX SKB to the RX queue associated with the driver's RX SCRQ.
This should improve the RX CPU load balancing issues seen by the
performance team.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4b2e128..4a2b99f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1428,6 +1428,7 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 
 		skb_put(skb, length);
 		skb->protocol = eth_type_trans(skb, netdev);
+		skb_record_rx_queue(skb, scrq_num);
 
 		if (flags & IBMVNIC_IP_CHKSUM_GOOD &&
 		    flags & IBMVNIC_TCP_UDP_CHKSUM_GOOD) {
