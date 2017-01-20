From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: qcom/emac: claim the irq only when the device is
 opened
Date: Fri, 20 Jan 2017 15:05:25 -0600
Message-ID: <0b4a0259-f281-9b25-ef63-a09ef6725746@codeaurora.org>
References: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
 <c86ba3d4-8393-f88d-2414-9295feb6d661@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45672 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdATVGB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 16:06:01 -0500
In-Reply-To: <c86ba3d4-8393-f88d-2414-9295feb6d661@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2017 02:44 PM, Lino Sanfilippo wrote:
>
>
> On 18.01.2017 22:42, Timur Tabi wrote:
>> @@ -1029,8 +1017,6 @@ void emac_mac_down(struct emac_adapter *adpt)
>>        */
>>       writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
>>       writel(0, adpt->base + EMAC_INT_MASK);
>> -    synchronize_irq(adpt->irq.irq);
>
> There is no reason to remove the irq synchronization, is it?
> Note that the desriptors are freed after that so we must be sure that
> the irq handler is not running any more.

I'm moving it to stay with the free_irq().

@@ -283,6 +292,9 @@ static int emac_close(struct net_device *netdev)

  	mutex_lock(&adpt->reset_lock);

+	synchronize_irq(adpt->irq.irq);
+	free_irq(adpt->irq.irq, &adpt->irq);
+

However, I'll admit that I don't know why we call synchronize_irq() at all.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
