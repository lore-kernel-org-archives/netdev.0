From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 21:09:28 +0200
Message-ID: <d54d0555-c448-741c-eb63-5a773bed5a30@free.fr>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <a75691d9-c22a-9b89-2cce-604315062739@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        David Daney <ddaney.cavm@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:25392 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750968AbdHaTJe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 15:09:34 -0400
In-Reply-To: <a75691d9-c22a-9b89-2cce-604315062739@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/2017 19:03, Florian Fainelli wrote:

> On 08/31/2017 05:29 AM, Marc Gonzalez wrote:
>
>> On 31/08/2017 02:49, Florian Fainelli wrote:
>>
>>> The original motivation for this change originated from Marc Gonzalez
>>> indicating that his network driver did not have its adjust_link callback
>>> executing with phydev->link = 0 while he was expecting it.
>>
>> I expect the core to call phy_adjust_link() for link changes.
>> This used to work back in 3.4 and was broken somewhere along
>> the way.
> 
> If that was working correctly in 3.4 surely we can look at the diff and
> figure out what changed, even maybe find the offending commit, can you
> do that?

Bisecting would a be a huge pain because my platform was
not upstream until v4.4

You mentioned the guarantees made by PHYLIB.
When is the adjust_link callback guaranteed to be called?

>>> PHYLIB has never made any such guarantees ever because phy_stop() merely
>>> just tells the workqueue to move into PHY_HALTED state which will happen
>>> asynchronously.
>>
>> My original proposal was to fix the issue in the driver.
>> I'll try locating it in my archives.
> 
> Yes I remember you telling that, by the way I don't think you ever
> provided a clear explanation why this is absolutely necessary for your
> driver though?

1) nb8800_link_reconfigure() calls phy_print_status()
which prints the "Link down" and "Link up" messages
to the console. With the patch reverted, nothing is
printed when the link goes down, and the result is
random when the link comes up. Sometimes, we get
down + up, sometimes just up.

2) nb8800_link_reconfigure() does some HW init when
the link state changes. If we miss some notifications,
we might not perform some HW init, and stuff breaks.

Regards.
