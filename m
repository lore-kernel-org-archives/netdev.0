From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net] ehea: fix operation state report
Date: Thu,  3 Nov 2016 08:16:20 -0200
Message-ID: <1478168180-18371-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: dougmill@linux.vnet.ibm.com, zhou@redhat.com,
        "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:58360 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756323AbcKCKRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 06:17:23 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA3AEFAh111540
        for <netdev@vger.kernel.org>; Thu, 3 Nov 2016 06:17:22 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26fykqq9jx-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:17:22 -0400
Received: from localhost
        by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Thu, 3 Nov 2016 08:17:19 -0200
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.18.232.225])
        by d24dlp02.br.ibm.com (Postfix) with ESMTP id 12D251DC0070
        for <netdev@vger.kernel.org>; Thu,  3 Nov 2016 06:16:31 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
        by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA3AGUvN32440408
        for <netdev@vger.kernel.org>; Thu, 3 Nov 2016 08:16:30 -0200
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
        by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA3AGULN013622
        for <netdev@vger.kernel.org>; Thu, 3 Nov 2016 08:16:30 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the ehea driver is missing a call to netif_carrier_off()
before the interface bring-up; this is necessary in order to
initialize the __LINK_STATE_NOCARRIER bit in the net_device state
field. Otherwise, we observe state UNKNOWN on "ip address" command
output.

This patch adds a call to netif_carrier_off() on ehea's net device
open callback.

Reported-by: Xiong Zhou <zhou@redhat.com>
Reference-ID: IBM bz #137702, Red Hat bz #1089134
Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 54efa9a..bd719e2 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -2446,6 +2446,8 @@ static int ehea_open(struct net_device *dev)
 
 	netif_info(port, ifup, dev, "enabling port\n");
 
+	netif_carrier_off(dev);
+
 	ret = ehea_up(dev);
 	if (!ret) {
 		port_napi_enable(port);
-- 
2.1.0
