From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Requirements for a shutdown function?
Date: Tue, 9 May 2017 11:46:40 -0700
Message-ID: <1721db9b-ed60-4556-9aac-81f17e2c1849@gmail.com>
References: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34656 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdEISqs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 14:46:48 -0400
Received: by mail-pf0-f194.google.com with SMTP id w69so986558pfk.1
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 11:46:48 -0700 (PDT)
In-Reply-To: <49bee65f-2ea8-1787-9642-659a967df8f0@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2017 09:58 AM, Timur Tabi wrote:
> I'm trying to add a platform_driver.shutdown function to my Ethernet driver
> (drivers/net/ethernet/qualcomm/emac/*), but I can't find any definitive
> information as to what a network driver shutdown callback is supposed to do.
>  I also don't know what testcase I should use to verify that my function is
> working.

A good test case for exercising a .shutdown() function is kexec'ing a
new kernel for instance.

> 
> I see only four instances of a platform_driver.shutdown function in
> drivers/net/ethernet:
> 
> $ git grep -A 20 -w platform_driver | grep '\.shutdown'
> apm/xgene-v2/main.c-	.shutdown = xge_shutdown,
> apm/xgene/xgene_enet_main.c-	.shutdown = xgene_enet_shutdown,
> marvell/mv643xx_eth.c-	.shutdown	= mv643xx_eth_shutdown,
> marvell/pxa168_eth.c-	.shutdown = pxa168_eth_shutdown,
> 
> (Other shutdown functions are for pci_driver.shutdown).
> 
> For the xgene drivers, the shutdown function just calls the 'remove'
> function.  Isn't that overkill?  Why bother with a shutdown function if it's
> just the same thing as removing the driver outright?

Yes, that appears unnecessary.

> 
> mv643xx_eth_shutdown() seems more reasonable.  All it does is halt the TX
> and RX queues.
> 
> pxa168_eth_shutdown() is a little more heavyweight: halts the queues, and
> stops the DMA and calls phy_stop().
> 
> Can anyone help me figure out what my driver really should do?

You should put your HW in a state where it won't be doing DMA, or have
any adverse side effects to the system, putting it in a low power state
is also a good approach.
-- 
Florian
