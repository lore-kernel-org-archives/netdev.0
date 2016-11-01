From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [RFC] net: phy: phy drivers should not set
 SUPPORTED_Pause or SUPPORTED_Asym_Pause
Date: Tue, 1 Nov 2016 14:19:56 -0500
Message-ID: <5818EADC.5060601@codeaurora.org>
References: <1478020715-25578-1-git-send-email-timur@codeaurora.org>
 <aa0224f1-814a-d281-ad26-6c8086e40658@gmail.com>
 <5818E2B0.80902@codeaurora.org>
 <be1c80d3-654a-65c8-3c5b-9a7bfbf8817d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49450 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752335AbcKATT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 15:19:58 -0400
In-Reply-To: <be1c80d3-654a-65c8-3c5b-9a7bfbf8817d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2016 02:03 PM, Florian Fainelli wrote:
> The standard (IEEE Std 802.3-2008) describes this as the
> Auto-negotiation advertisement register and these bits are part of the
> Technology ability field register. These two bits A5 (PAUSE operation
> for full duplex links) and A6 (Asymetric PAUSE operation for full duplex
> links) have no cabling requirement, and earlier the paragraph mentions
> this is to be resolved by the "management" entity, so I don't think the
> PHY has any business in that other than reflecting what the MAC is
> capable of doing towards the link partner, but I could be reading the
> specification incorrectly.

Fair enough.  I'll post a V2 patch that enables those bits in phy.c.

On a side note, is there any reason for the MAC to ever disable support 
for accepting pause frames?  If the PHY is configured to not advertise 
support for receiving pause frames, then does it matter if the MAC is 
configured to accept them?  The MAC would never receive such a frame.

If so, then I can modify my other patch (net: qcom/emac: enable flow 
control if requested) to always set RXFC, and have it set TXFC only if 
the PHY will transmit pause frames.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
