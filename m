From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH] net: phy: fix auto-negotiation stall due to unavailable
 interrupt
Date: Thu, 20 Apr 2017 12:21:10 +0300
Message-ID: <3b0cca7f-bffe-0717-fbea-7d9ba47a858f@ti.com>
References: <1492609604-16359-1-git-send-email-al.kochet@gmail.com>
 <24E19B31-CCD8-4032-B17B-D226D4DB881D@gmail.com>
 <754f7cfe-6914-570a-d0e5-4a26b6787281@gmail.com>
 <EA84802B-82E6-4485-A92E-E2751A84D4D0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <andrew@lunn.ch>, <nsekhar@ti.com>, <kyle.roeschley@ni.com>
To: Alexander Kochetkov <al.kochet@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:42744 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940010AbdDTJVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 05:21:24 -0400
In-Reply-To: <EA84802B-82E6-4485-A92E-E2751A84D4D0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 19/04/17 19:53, Alexander Kochetkov wrote:
> 
>> 19 апр. 2017 г., в 19:32, Florian Fainelli <f.fainelli@gmail.com> написал(а):
>>
>> http://patchwork.ozlabs.org/patch/743773/
>>
>> Roger can you also test Alexander's patch?

This patch fixes my problem and doesn't have the 1 second delay that my patch had.

So,

Tested-by: Roger Quadros <rogerq@ti.com>

> 
> If MAC use phy_start_aneg() instead of phy_start() my patch will not work as
> expected. Roger, if patch don’t work for you please check what MAC bring up PHY using
> phy_start():

Our MAC driver is using phy_start() and I didn't face any issues with your patch.

> 
> http://patchwork.ozlabs.org/patch/752308/
> 
> Is it correct to start PHY inside MAC probe using phy_start_aneg()? Or phy_start() must be used?
> 
> And probably this tags should be added for my patch:
> Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
> Cc: stable <stable@vger.kernel.org> # v4.9+
> 
> Because I bisected to commit 529ed1275263 ("net: phy: phy drivers
> should not set SUPPORTED_[Asym_]Pause») that looks pretty good.
> 
> Also, there is another issue I found. link_timeout doesn’t work for interrupt driven PHY.
> It is possible to implement timer to handle this case.
> Florian, what do you think? Should this be fixed?
> 
> Alexander.
> 

cheers,
-roger
