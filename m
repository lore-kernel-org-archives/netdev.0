From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 14:28:34 -0700
Message-ID: <27f6d81d-50b1-a585-e251-2303957130d9@gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@qti.qualcomm.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34592 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941010AbdEXV2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 17:28:40 -0400
Received: by mail-wr0-f194.google.com with SMTP id 6so10917343wrb.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 14:28:40 -0700 (PDT)
In-Reply-To: <45f80817-ec17-51c0-3816-f7c93e6aeeb9@quicinc.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 02:20 PM, Timur Tabi wrote:
> On 05/24/2017 04:15 PM, Andrew Lunn wrote:
>>> My NIC has a feature called autopolling where it takes over the MDIO
>>> bus and regularly polls the link state.  When it detects that the
>>> link state has changed, it generates a MAC interrupt.  This is when
>>> I call phy_mac_interrupt() normally.
> 
>> Unfortunately, you need to keep this feature turned off. It will not
>> respect the phydev mutex. It has no idea what page has been currently
>> selected. It probably has no way to flip the page and see if the SGMII
>> link is up. etc.
> 
> phydev mutex?  And what do you mean by page?

Yes phydev->lock which is used to serialize the state machine state changes.

Most PHYs have many more registers than the 15 standard exposed
directly, and so you need indirect reads/writes to access these
registers, which typically involve switching a particular page, doing
the indirect register access, and then flipping the page back. If you
interrupt that scheme one way or another, your reads and writes are all
messed up.

> 
> I forgot one detail.  Every time you do an MDIO read/write, it
> temporarily disables the feature.  Although, I think that's not relevant
> to your point.

Is that done by the HW itself, or is this under SW control exclusively.

> 
> Disabling this feature and switching from PHY_IGNORE_INTERRUPT to
> PHY_POLL might fix everything.  I will try it.
> 

Humm yes, that seems like a worthwhile exercise at least.
-- 
Florian
