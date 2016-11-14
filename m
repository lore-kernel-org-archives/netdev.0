From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC
 level
Date: Mon, 14 Nov 2016 14:22:46 +0100
Message-ID: <5829BAA6.20905@laposte.net>
References: <581CA300.1060609@laposte.net>
 <yw1xlgwzjmti.fsf@unicorn.mansr.com> <581CAB12.3030604@laposte.net>
 <b792b229-6126-c3a7-e071-bdd93fe51626@gmail.com>
 <yw1x1syrjil8.fsf@unicorn.mansr.com> <58231E6C.2040603@laposte.net>
 <0fc519a7-6e42-de55-7a4a-c7dc9d64c5db@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
        =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz27.laposte.net ([194.117.213.102]:34890 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751167AbcKNNWt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 08:22:49 -0500
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout015 (Postfix) with ESMTP id 575EE1C9425
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:22:47 +0100 (CET)
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout015 (Postfix) with ESMTP id 47C691C943C
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:22:47 +0100 (CET)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.prosodie [10.128.63.2])
        by lpn-prd-vrout015 (Postfix) with ESMTP id 435DB1C9425
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:22:47 +0100 (CET)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
        by lpn-prd-vrin001 (Postfix) with ESMTP id 279C9366D93
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:22:47 +0100 (CET)
In-Reply-To: <0fc519a7-6e42-de55-7a4a-c7dc9d64c5db@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2016 06:03 PM, Florian Fainelli wrote:
> On 11/09/2016 05:02 AM, Sebastian Frias wrote:
>> On 11/04/2016 05:49 PM, Måns Rullgård wrote:
>>>>> But when doing so, both the Atheros 8035 and the Aurora NB8800 drivers
>>>>> will apply the delay.
>>>>>
>>>>> I think a better way of dealing with this is that both, PHY and MAC
>>>>> drivers exchange information so that the delay is applied only once.
>>>>
>>>> Exchange what information? The PHY device interface (phydev->interface)
>>>> conveys the needed information for both entities.
>>>
>>> There doesn't seem to be any consensus among the drivers regarding where
>>> the delay should be applied.  Since only a few drivers, MAC or PHY, act
>>> on this property, most combinations still work by chance.  It is common
>>> for boards to set the delay at the PHY using external config pins so no
>>> software setup is required (although I have one Sigma based board that
>>> gets this wrong).  I suspect if drivers/net/ethernet/broadcom/genet were
>>> used with one of the four PHY drivers that also set the delay based on
>>> this DT property, things would go wrong.
>>>
>>
>> Exactly, what about a patch like (I can make a formal submission, even
>> merge it with the patch discussed in this thread, consider this a RFC):
> 
> I really don't see a point in doing this when we can just clarify what
> phydev->interface does and already have the knowledge that we need
> without introducing additional flags in the phy driver.
> 

Ok, so who can clarify what "phydev->interface" does, especially in the
context of this discussion?

What happens when a TX delay must be applied and:
  - both the PHY and the MAC support the delay
  - only the PHY supports the delay
  - only the MAC supports the delay

Best regards,

Sebastian
