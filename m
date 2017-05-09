From: Timur Tabi <timur@codeaurora.org>
Subject: Requirements for a shutdown function?
Date: Tue, 9 May 2017 11:58:32 -0500
Message-ID: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37040 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754330AbdEIQ6e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 12:58:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to add a platform_driver.shutdown function to my Ethernet driver
(drivers/net/ethernet/qualcomm/emac/*), but I can't find any definitive
information as to what a network driver shutdown callback is supposed to do.
 I also don't know what testcase I should use to verify that my function is
working.

I see only four instances of a platform_driver.shutdown function in
drivers/net/ethernet:

$ git grep -A 20 -w platform_driver | grep '\.shutdown'
apm/xgene-v2/main.c-	.shutdown = xge_shutdown,
apm/xgene/xgene_enet_main.c-	.shutdown = xgene_enet_shutdown,
marvell/mv643xx_eth.c-	.shutdown	= mv643xx_eth_shutdown,
marvell/pxa168_eth.c-	.shutdown = pxa168_eth_shutdown,

(Other shutdown functions are for pci_driver.shutdown).

For the xgene drivers, the shutdown function just calls the 'remove'
function.  Isn't that overkill?  Why bother with a shutdown function if it's
just the same thing as removing the driver outright?

mv643xx_eth_shutdown() seems more reasonable.  All it does is halt the TX
and RX queues.

pxa168_eth_shutdown() is a little more heavyweight: halts the queues, and
stops the DMA and calls phy_stop().

Can anyone help me figure out what my driver really should do?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
