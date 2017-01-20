From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] net: qcom/emac: claim the irq only when the device is
 opened
Date: Fri, 20 Jan 2017 22:31:09 +0100
Message-ID: <4025bb82-bc41-abfd-1481-5e66abc25c65@gmx.de>
References: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
 <c86ba3d4-8393-f88d-2414-9295feb6d661@gmx.de>
 <0b4a0259-f281-9b25-ef63-a09ef6725746@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:57210 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752243AbdATVbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 16:31:25 -0500
In-Reply-To: <0b4a0259-f281-9b25-ef63-a09ef6725746@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20.01.2017 22:05, Timur Tabi wrote:
> On 01/20/2017 02:44 PM, Lino Sanfilippo wrote:
>>
>>
>> On 18.01.2017 22:42, Timur Tabi wrote:
>>> @@ -1029,8 +1017,6 @@ void emac_mac_down(struct emac_adapter *adpt)
>>>        */
>>>       writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
>>>       writel(0, adpt->base + EMAC_INT_MASK);
>>> -    synchronize_irq(adpt->irq.irq);
>>
>> There is no reason to remove the irq synchronization, is it?
>> Note that the desriptors are freed after that so we must be sure that
>> the irq handler is not running any more.
>
> I'm moving it to stay with the free_irq().
>
> @@ -283,6 +292,9 @@ static int emac_close(struct net_device *netdev)
>
>      mutex_lock(&adpt->reset_lock);
>
> +    synchronize_irq(adpt->irq.irq);
> +    free_irq(adpt->irq.irq, &adpt->irq);
> +
>
> However, I'll admit that I don't know why we call synchronize_irq() at 
> all.
>

free_irq() will call synchronize_irq() if necessary, so it is pointless 
to call synchronize_irq()
right before free_irq().
In emac_mac_down() however we need synchronize_irq(), since it ensures 
that the irq
handler is not running any more when it (synchronize_irq) returns.

Regards,
Lino
