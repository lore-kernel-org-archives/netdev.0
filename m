From: Timur Tabi <timur@qti.qualcomm.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 16:32:48 -0500
Message-ID: <bde05752-8dcf-9c69-0677-39a12e67edeb@quicinc.com>
References: <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
 <20170524134021.GA26577@lunn.ch>
 <8cf4ca6d-3e1e-3c9c-605f-5d6baf3c7588@codeaurora.org>
 <20170524140929.GC26577@lunn.ch>
 <c2a54e2e-a1b6-24b4-d125-95fa9648fe95@codeaurora.org>
 <20170524193450.GC1788@lunn.ch>
 <d6a23db1-2465-b315-f520-63aba0341fbe@quicinc.com>
 <20170524211520.GJ1788@lunn.ch>
 <45f80817-ec17-51c0-3816-f7c93e6aeeb9@quicinc.com>
 <27f6d81d-50b1-a585-e251-2303957130d9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, <jhugo@codeaurora.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@qti.qualcomm.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:2026 "EHLO
        wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941010AbdEXVcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 17:32:51 -0400
In-Reply-To: <27f6d81d-50b1-a585-e251-2303957130d9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 04:28 PM, Florian Fainelli wrote:

> Yes phydev->lock which is used to serialize the state machine state changes.
>
> Most PHYs have many more registers than the 15 standard exposed
> directly, and so you need indirect reads/writes to access these
> registers, which typically involve switching a particular page, doing
> the indirect register access, and then flipping the page back. If you
> interrupt that scheme one way or another, your reads and writes are all
> messed up.

Ah, and the at803x is a device like that.

At worst, the autopoll feature could read a register from the wrong 
page, and think that the link state has changed when it hasn't.  But 
that's still bad, and all my problems do revolve around link states.

>> I forgot one detail.  Every time you do an MDIO read/write, it
>> temporarily disables the feature.  Although, I think that's not relevant
>> to your point.
>
> Is that done by the HW itself, or is this under SW control exclusively.

Software.
