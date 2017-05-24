From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 08:48:04 -0500
Message-ID: <8cf4ca6d-3e1e-3c9c-605f-5d6baf3c7588@codeaurora.org>
References: <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <66de55da-7a5c-68b8-50d5-cab313ec0d6f@codeaurora.org>
 <20170522210927.GR29447@lunn.ch>
 <0d9b30e5-40f3-82ba-a44a-2eb25b8d3094@codeaurora.org>
 <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
 <20170524134021.GA26577@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, f.fainelli@gmail.com,
        David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47166 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935319AbdEXNsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 09:48:06 -0400
In-Reply-To: <20170524134021.GA26577@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/24/17 8:40 AM, Andrew Lunn wrote:

> You need to prove this, that the link is not up. Any by link, we mean
> both the copper and the SGMII link.

I can post the log of my iperf run showing that the, when 
at803x_aneg_done() returns zero, no packets can go through.  And then 
after I change at803x_aneg_done() so that it returns BMSR_ANEGCOMPLETE, 
then packets do go through.  Is that the proof you're looking for?

The current work-around that we're using internally is to blacklist the 
at803x driver.  This forces the kernel to use the genphy driver instead. 
  Everything works when we do this.

>> at803x_aneg_done() is never called again, and so I think
>> the kernel is disabling the interface is some secret way.
> 
> Well, the driver has told the core that the link is not up. So the
> kernel is waiting for another interrupt indicating the link has gone
> up. And probably, this second interrupt never happens.

Exxactly.  That's because the link IS up, and so there is no opportunity 
to receive another interrupt.

> And it is not disabling the interface. Since the PHY is still down,
> the core has not called netif_carrier_on().

Ok, I should have said "not enabled" instead of "disabled".  Thanks.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
