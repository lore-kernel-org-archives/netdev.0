From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Need help with mdiobus_register and phy
Date: Sat, 15 Oct 2016 12:19:22 +0200
Message-ID: <535FE9FE-0D69-4874-BBF0-F0662C2157DB@gmail.com>
References: <20161014040641.GE5822@lunn.ch> <5800C3C7.60705@codeaurora.org> <20161014120624.GG5822@lunn.ch> <5800D214.70808@codeaurora.org> <20161014124928.GJ5822@lunn.ch> <5800D474.1030303@codeaurora.org> <20161014125736.GK5822@lunn.ch> <5800D796.1030602@codeaurora.org> <20161014131852.GM5822@lunn.ch> <58010E79.2030607@codeaurora.org> <20161014172514.GA23455@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35303 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752505AbcJOKTc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 06:19:32 -0400
Received: by mail-wm0-f50.google.com with SMTP id c78so24690004wme.0
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 03:19:31 -0700 (PDT)
In-Reply-To: <20161014172514.GA23455@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On October 14, 2016 7:25:14 PM CEST, Andrew Lunn <andrew@lunn.ch> wrote:

>> So after calling BMCR_PDOWN, the PHYSID1 and PHYSID2 registers are
>> no longer readable.  Is that expected?
>
>You are making two changes here. Is it the SGMII power down which is
>causing the id registers to return 0xffff, or the BMCR_PDOWN.

I would be curious to know about that as well.

>
>The generic suspend code sets the PDOWN bit, so it is assuming the PHY
>will respond afterwards.

After reading the spec again, it does not appear to me that a PHY with PDOWN set is guaranteed or even required to respond to other register reads such as MII_PHYID1/2, in which case we may have to implement a MDIO bus reset routine which clears PDOWN for all PHYs that we detect(ed), or as Andrew suggested, utilize the matching by compatible string with the PHY OUI in it.

-- 
Florian
