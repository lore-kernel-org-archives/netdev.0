From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: fix Tx ring priority programming
Date: Tue, 7 Oct 2014 09:09:20 -0700
Message-ID: <CAGXr9JGL535nJ9SC9iA1P_tt39zA7T672adoWd9GqaqM_jHafA@mail.gmail.com>
References: <20141007005001.61C1D100BC1@puck.mtv.corp.google.com>
	<20141006.235926.30933585433924137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f178.google.com ([209.85.220.178]:56896 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198AbaJGQJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:09:21 -0400
Received: by mail-vc0-f178.google.com with SMTP id hq12so5178444vcb.9
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 09:09:20 -0700 (PDT)
In-Reply-To: <20141006.235926.30933585433924137.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Oct 6, 2014 at 8:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Petri Gynther <pgynther@google.com>
> Date: Mon,  6 Oct 2014 17:50:01 -0700 (PDT)
>
>> @@ -1731,11 +1744,12 @@ static void bcmgenet_init_multiq(struct net_device *dev)
>>       reg |= ring_cfg;
>>       bcmgenet_tdma_writel(priv, reg, DMA_RING_CFG);
>>
>> -     /* Use configured rings priority and set ring #16 priority */
>> -     reg = bcmgenet_tdma_readl(priv, DMA_RING_PRIORITY);
>> -     reg |= ((GENET_Q0_PRIORITY + priv->hw_params->tx_queues) << 20);
>> -     reg |= dma_priority;
>> -     bcmgenet_tdma_writel(priv, reg, DMA_PRIORITY);
>> +     /* Set ring 16 priority and program the hardware registers */
>> +     dma_priority[2] |=
>> +             ((GENET_Q0_PRIORITY + priv->hw_params->tx_queues) << 20);
>
> Please use "<< (16 - 12) * DMA_RING_BUF_PRIORITY_SHIFT" otherwise this
> constant is magic.
>
> You might, optionally, add macros for the subtraction adjustment each
> priority register uses (0, 6, 12, respectively).

Thanks for the comments. I'm going to simplify this with a few macros.
