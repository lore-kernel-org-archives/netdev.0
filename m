From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Thu, 1 Jun 2017 09:48:07 -0500
Message-ID: <41274ef3-517a-5e6f-a44b-ef060f62e9a5@codeaurora.org>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210927.GR29447@lunn.ch>
 <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
 <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
 <265ee4d4-ce24-9e0f-d7c5-fba4ed36ab96@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Matthias May <matthias.may@neratec.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:32924 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdFAOsK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 10:48:10 -0400
In-Reply-To: <265ee4d4-ce24-9e0f-d7c5-fba4ed36ab96@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2017 06:45 AM, Zefir Kurtisi wrote:
> I guess we need to decide whether we generally need to handle permanent aneg
> failures on the SGMII link. If we expect that it must not fail (like we assumed
> until we saw it failing), I agree with Timur and support reverting of the related
> commit f62265b53e. If otherwise we want this potential failure to be handled
> correctly, things become arbitrary complex. Essentially, we need to handle such
> PHYs as a combination of their two sides (copper + SGMII) as virtual sub-PHYs. The
> phylib might support that in a future version, but for now this seems like a lot
> of work required to handle a rare problem.

I'm about to post a patch that removes interrupt support from the EMAC 
driver and relies on software polling of the PHY.  With this patch, we 
don't see the "link is not okay" message from that at803x driver any more.

The link state is generally more reliable now, even when the at803x 
driver doesn't complain.

My theory is that the hardware polling of the PHY is just too 
aggressive.  I think it continuously reads the PHY status register at 
maximum speed and immediately issues an interrupt when the PHY says that 
it's up.

So I think we're okay with leaving the at803x driver as-is, since we 
appear to be no longer getting any false failures.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
