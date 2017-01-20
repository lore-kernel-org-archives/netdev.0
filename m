From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] net: qcom/emac: claim the irq only when the device is
 opened
Date: Fri, 20 Jan 2017 21:44:09 +0100
Message-ID: <c86ba3d4-8393-f88d-2414-9295feb6d661@gmx.de>
References: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:54150 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753354AbdATUpW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 15:45:22 -0500
In-Reply-To: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 18.01.2017 22:42, Timur Tabi wrote:
> @@ -1029,8 +1017,6 @@ void emac_mac_down(struct emac_adapter *adpt)
>   	 */
>   	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
>   	writel(0, adpt->base + EMAC_INT_MASK);
> -	synchronize_irq(adpt->irq.irq);

There is no reason to remove the irq synchronization, is it?
Note that the desriptors are freed after that so we must be sure that
the irq handler is not running any more.

Regards,
Lino
