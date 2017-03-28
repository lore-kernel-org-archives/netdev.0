From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Mon, 27 Mar 2017 21:14:00 -0700
Message-ID: <ad5368cf-8f89-c884-607d-8ac560ccc860@gmail.com>
References: <1490662190.3177.91.camel@kernel.crashing.org>
 <20170328010940.GG25549@lunn.ch>
 <1490668137.3177.98.camel@kernel.crashing.org>
 <1490669734.3177.100.camel@au1.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Russell King <rmk+kernel@armlinux.org.uk>
To: benh@au1.ibm.com, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35287 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbdC1EOb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 00:14:31 -0400
Received: by mail-oi0-f68.google.com with SMTP id t7so905892oig.2
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 21:14:01 -0700 (PDT)
In-Reply-To: <1490669734.3177.100.camel@au1.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On 03/27/2017 07:55 PM, Benjamin Herrenschmidt wrote:
> On Tue, 2017-03-28 at 13:28 +1100, Benjamin Herrenschmidt wrote:
>>
>>> Hi Ben
>>>
>>> It is worth reading Documentation/networking/phy.txt
>>>
>>> The MAC should set SUPPORTED_Pause and SUPPORTED_Asym_Pause if the MAC
>>> supports these features. The PHY will then negotiate them.
>>
> Haha ! The OpenBMC kernel is still at 4.7 which was still saying you
> should only clear bits in there :-) I think that's what I initially
> read.
> 
> Thanks for the pointer.
> 
> Doesn't fix my other problem with Pause in 1000bT land. Do you know if
> that way of reflecting the pause capability by hijacking the old
> LPA bits is widely implemented enough that we should put it in
> genphy_read_status() ?

Not sure I follow you here? The link partner pause capability is
reflected in phydev->pause and phydev->asym_pause (yes, these are
terrible names) when the link is established. An Ethernet driver is
still supposed to reconcile the locally advertised pause parameters
(auto negotiated, or manually configured) from ethtool_{get,set}_param
and then decide what to do in return (typically advertise or not the
support for pause frames).

The plan is eventually to provide better helper function for PHYLIB
aware Ethernet MAC drivers such that given the local pause settings of
the driver (resolved via ethtool), advertisement and auto-(re)negotation
works as expected, essentially providing something generic ala
tg3_set_pauseparam().

Have not gotten the time to get there yet so if you, or Russell beat me
to it, I'd happily review such patches.
-- 
Florian
