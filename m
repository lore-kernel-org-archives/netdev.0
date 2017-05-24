From: Timur Tabi <timur@qti.qualcomm.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 16:20:16 -0500
Message-ID: <45f80817-ec17-51c0-3816-f7c93e6aeeb9@quicinc.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, <jhugo@codeaurora.org>
To: Andrew Lunn <andrew@lunn.ch>, Timur Tabi <timur@qti.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:40578 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032657AbdEXVUT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 17:20:19 -0400
In-Reply-To: <20170524211520.GJ1788@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 04:15 PM, Andrew Lunn wrote:
>> My NIC has a feature called autopolling where it takes over the MDIO
>> bus and regularly polls the link state.  When it detects that the
>> link state has changed, it generates a MAC interrupt.  This is when
>> I call phy_mac_interrupt() normally.

> Unfortunately, you need to keep this feature turned off. It will not
> respect the phydev mutex. It has no idea what page has been currently
> selected. It probably has no way to flip the page and see if the SGMII
> link is up. etc.

phydev mutex?  And what do you mean by page?

I forgot one detail.  Every time you do an MDIO read/write, it 
temporarily disables the feature.  Although, I think that's not relevant 
to your point.

Disabling this feature and switching from PHY_IGNORE_INTERRUPT to 
PHY_POLL might fix everything.  I will try it.
