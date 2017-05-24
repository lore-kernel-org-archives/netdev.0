From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 08:29:03 -0500
Message-ID: <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>, netdev@vger.kernel.org,
        f.fainelli@gmail.com, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Matthias May <matthias.may@neratec.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37924 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761687AbdEXN3G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 09:29:06 -0400
In-Reply-To: <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/24/17 2:18 AM, Matthias May wrote:
> With the patch: When the copper side is seen as up, it also checks if aneg of the SGMII link is done.
> As far as i know SGMII can not be run without aneg, since it is always Gbit with aneg mandatory.
> If SGMII aneg is not done, then, well aneg is not done and thus 0 is returned.
> 
> Internally we have this patch extended so we don't only report that aneg is not done but also reset the link.
> Eventually aneg on the SGMII side can be completed and the link comes up.

I would really like to test this patch.

> Why do you think that frames are able to go through when aneg is reported as not done by the PHY?

I have two theories:

1. The warning message is bogus.  The link actually is okay, but the 
driver thinks that it isn't.

2. The link is not okay, but it automatically fixes itself soon after 
the at803x_aneg_done() finishes.

> Since aneg is mandatory for SGMII this can as well be seen as "link not up", not?

The problem is that even though the link is up, the driver has returned 
"0", so the kernel thinks that autonegotiation has not finished. 
at803x_aneg_done() is never called again, and so I think the kernel is 
disabling the interface is some secret way.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
