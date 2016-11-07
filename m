From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [RFC] net: phy: phy drivers should not set
 SUPPORTED_Pause or SUPPORTED_Asym_Pause
Date: Mon, 7 Nov 2016 10:30:21 -0600
Message-ID: <5820AC1D.4040408@codeaurora.org>
References: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
 <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60292 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753109AbcKGQav (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 11:30:51 -0500
In-Reply-To: <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 01:35 PM, Florian Fainelli wrote:
> So in premise, this is good, and is exactly what I have in mind for the
> series that I am cooking, but if we apply this alone, without a change
> in drivers/net/phy/phy.c which adds SUPPORTED_Pause |
> SUPPORTED_AsymPause to phydev->features, we are basically breaking the
> Ethernet MAC drivers that don't explicitly override phydev->features and
> yet rely on that to get flow control to work.

Can you tell me where I should set the SUPPORTED_Pause and 
SUPPORTED_AsymPause flags?  I have a two candidates:

1. The settings[] array.  Add these flags to each entry.

2. In phy_sanitize_settings().  Add

	phydev->supported |= SUPPORTED_Pause | SUPPORTED_AsymPause;

at the end of the function.


I'm still don't understand 100% how these flags really work, because I 
just can't shake the feeling that they should not be set for every phy. 
  If these flags are supposed to be turned on universally, then why are 
they even an option?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
