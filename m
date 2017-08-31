From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 19:35:05 +0200
Message-ID: <e5063ab9-643b-15eb-290d-bdfba3b5fd28@free.fr>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: David Daney <ddaney.cavm@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:31717 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751622AbdHaRfM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 13:35:12 -0400
In-Reply-To: <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/2017 18:36, David Daney wrote:
> On 08/31/2017 05:29 AM, Marc Gonzalez wrote:
>> On 31/08/2017 02:49, Florian Fainelli wrote:
>>
>>> This reverts commit 7ad813f208533cebfcc32d3d7474dc1677d1b09a ("net: phy:
>>> Correctly process PHY_HALTED in phy_stop_machine()") because it is
>>> creating the possibility for a NULL pointer dereference.
>>>
>>> David Daney provide the following call trace and diagram of events:
>>>
>>> When ndo_stop() is called we call:
>>>
>>>   phy_disconnect()
>>>      +---> phy_stop_interrupts() implies: phydev->irq = PHY_POLL;
>>
>> What does this mean?
> 
> I meant that after the call to phy_stop_interrupts(), phydev->irq = 
> PHY_POLL;

I must be missing something.

http://elixir.free-electrons.com/linux/latest/source/drivers/net/phy/phy.c#L868

phy_stop_interrupts() doesn't change phydev->irq right?

Only phy_start_interrupts() sets phydev->irq to
PHY_POLL if it cannot set up interrupt mode.

Regards.
