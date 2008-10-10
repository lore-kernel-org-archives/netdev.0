From: wendy xiong <wendyx@us.ibm.com>
Subject: [PATCH 1/1 2.6.28] cxgb3 - add one check in interrupt routine
Date: Fri, 10 Oct 2008 15:48:48 -0500
Message-ID: <1223671728.2614.13.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	wenxiong@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:36682 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758568AbYJJUtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 16:49:00 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9AKmwN9014718
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 16:48:58 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9AKmwhx216154
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 14:48:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9AKmMU2007112
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 14:48:28 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

We are submitting a patch to do the test before accessing A_PL_CLI register in interrupt routine for inclusion in 2.6.28, 
as follows:


diff -Nuarp linux-2.6.27-rc9/drivers/net/cxgb3/sge.c linux-2.6.27-rc9.cxgb3/drivers/net/cxgb3/sge.c
--- linux-2.6.27-rc9/drivers/net/cxgb3/sge.c    2008-10-10 15:09:31.000000000 -0500
+++ linux-2.6.27-rc9.cxgb3/drivers/net/cxgb3/sge.c      2008-10-10 15:11:44.000000000 -0500
@@ -2691,6 +2691,9 @@ static irqreturn_t t3b_intr_napi(int irq
        t3_write_reg(adap, A_PL_CLI, 0);
        map = t3_read_reg(adap, A_SG_DATA_INTR);

+       if (unlikely(pci_channel_offline(adap->pdev)))
+               return IRQ_NONE;
+
        if (unlikely(!map))     /* shared interrupt, most likely */
                return IRQ_NONE;


Thanks,
Wendy




