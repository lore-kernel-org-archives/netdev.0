From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: phy: at803x: the Atheros 8031 supports pause frames
Date: Thu, 27 Oct 2016 17:24:14 -0500
Message-ID: <58127E8E.4020301@codeaurora.org>
References: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
 <f34cd143-bf04-c17f-b3d6-e3077715a72a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        zefir.kurtisi@neratec.com, scampbel@codeaurora.org,
        alokc@codeaurora.org, shankerd@codeaurora.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55392 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941575AbcJ0WYf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 18:24:35 -0400
In-Reply-To: <f34cd143-bf04-c17f-b3d6-e3077715a72a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:

> Hu? In my experience that should not come from supporting Pause frames
> or not, but rather properly configuring a (RG)MII delay, but your
> mileage may vary.

I can assure you, I'm more confused than you.  I've been working in this 
for almost two weeks, and not only does this patch align with other phy 
drivers, but it does fix my bug.  Without this patch, phylib does not 
set the pause frame bits (10 and 11) in MII_ADVERTISE.

> It does not, support for Pause frames is a MAC-level feature, yet,
> PHYLIB (and that's been on my todo for a while now) insists on reporting
> the confusing phydev->pause and phydev->asym_pause, which really is what
> has been determined from auto-negotiating with your partner, as opposed
> to being a supported thing or not. The PHY has absolutely not business
> in that.

But there are pause frame bits in the MII_ADVERTISE register, and this 
setting directly impacts whether those bits are set.  I don't see how 
this is a MAC-level feature.

> Your change should probably be in the Ethernet MAC driver, when you have
> successfully connected to the PHY, update phydev->supported to include
> SUPPORTED_Pause | SUPPORTED_Asym_pause.

The phylib documentation (networking/phy.txt) says:

  Now just make sure that phydev->supported and phydev->advertising have any
  values pruned from them which don't make sense for your controller (a 
10/100
  controller may be connected to a gigabit capable PHY, so you would need to
  mask off SUPPORTED_1000baseT*).  See include/linux/ethtool.h for 
definitions
  for these bitfields.

and then it says:

> Note that you should not SET any bits, or the PHY may
>  get put into an unsupported state.

So are you sure I'm supposed to set those bits?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
