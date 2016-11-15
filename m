From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit
 ethernet driver
Date: Tue, 15 Nov 2016 22:24:59 +0100
Message-ID: <0d1b4dee-11bb-3605-699c-ea417484cb68@gmx.de>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
 <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161113195544.GA18258@lunn.ch>
 <69558f55-824a-7063-d9b3-ccc0a6113b87@gmx.de>
 <4450caf4-e1cf-5187-1337-c46b81b08708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:60987 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752308AbcKOVZR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 16:25:17 -0500
In-Reply-To: <4450caf4-e1cf-5187-1337-c46b81b08708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 15.11.2016 21:54, Florian Fainelli wrote:
> On 11/15/2016 12:46 PM, Lino Sanfilippo wrote:
>>> Could this be pulled out into a standard PHY driver? All the SLIC
>>> SLIC_PCR_ defines seems to be the same as those in mii.h. This could
>>> be a standard PHY hidden behind a single register.
>>>
>>>    Andrew
>> 
>> You are right, the driver should really use the defines in mii.h. I will fix this in
>>  a v2.
>> 
>> Concerning the use of the PHY API: What would be the advantage of using it? Note that the
>>  phy is always internal and not interchangeable. Is not the interchangeability of PHYs
>> the main reason for using this API?
> 
> Not reinventing the wheel primarily, while PHYLIB also solves the plug &
> play aspect of external PHYs, it also solves the basic link management,
> and consistent and reasonably well defined interface to user-space and
> drivers (statistics reporting, link, auto-negotiation, EEE etc.).
> 

Sure I see this point. But currently all the driver does concerning the phy is to
configure it for auto negotiation when the interface is brought up, nothing else.

The link state is retrieved by a command to the application processor that is running 
on the network card. Also the register to set the phy configuration is write-only, so
it is not even possible to do the usual mdio bit-banging in the Phy read() and write()
functions (however there seems to be another application processor command reserved 
for retrieving the PHY settings, but I have not tried it yet). 
Please also note that I do not have any datasheets or other documentation for the hardware, 
all I have as a reference is the driver code in staging. So I do not know which 
PHYs are actually used (the comments in the code mention Marvell and Cicada but this is
not very specific).

Regards,
Lino
