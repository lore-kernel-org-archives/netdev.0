From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 17:03:39 -0500
Message-ID: <d0aa5ce2-d9d2-b8be-67f1-2e8e90929b8d@codeaurora.org>
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
 <bde05752-8dcf-9c69-0677-39a12e67edeb@quicinc.com>
 <500e4d46-977b-bb6f-9252-cb6990288a84@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53154 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161117AbdEXWDn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 18:03:43 -0400
In-Reply-To: <500e4d46-977b-bb6f-9252-cb6990288a84@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 04:36 PM, Florian Fainelli wrote:
> OK, and there is no way you can run into the following race condition:
>
> CPU				HW
> MDIO read intent
> 				polling starts
> disable HW autopoll
> 				polling continues

Disabling of the HW autopoll waits for the poll to actually stop before 
continuing.  You can see the code here:

http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/qualcomm/emac/emac-phy.c#L102

> MDIO read is done
> 				MDIO read done
> 				polling stops
> MDIO read value returned
>
>
> if you disable autopolling in HW this is guaranteed to immediately stop
> by the time the register value is seen in HW and your I/O read/write
> returns?

It doesn't immediately stop, but the emac_phy_mdio_autopoll_disable() 
function waits for the MDIO bus to not be busy.  But low-level details 
of this feature are not documented, so who knows what it does exactly? 
The original code that used this feature only supported one PHY and 
never expected there to be any asynchronous MDIO transactios.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
