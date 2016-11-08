From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [RFC] net: phy: phy drivers should not set
 SUPPORTED_Pause or SUPPORTED_Asym_Pause
Date: Tue, 8 Nov 2016 14:43:31 -0600
Message-ID: <582238F3.30906@codeaurora.org>
References: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
 <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
 <5820AC1D.4040408@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:34668 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752640AbcKHUne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 15:43:34 -0500
In-Reply-To: <5820AC1D.4040408@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2016 10:30 AM, Timur Tabi wrote:
>
> I'm still don't understand 100% how these flags really work, because I
> just can't shake the feeling that they should not be set for every phy.
>   If these flags are supposed to be turned on universally, then why are
> they even an option?

So I've been giving this more thought.  Can you tell me if the following 
is correct:

1) PHY drivers and/or phylib sets the SUPPORTED_Pause | 
SUPPORTED_AsymPause bits in phydev->supported.  This indicates that the 
PHY supports pause frames.

2) The MAC driver checks phydev->supported before it calls phy_start(). 
  If (SUPPORTED_Pause | SUPPORTED_AsymPause) is set, then it sets those 
bits in phydev->advertising if it wants to enable pause frame support.

3) When the link state changes, the MAC driver checks 
phydev->advertising, and if the bits are set, then it enables those 
features in the MAC.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
