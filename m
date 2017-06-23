From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 2/3] net: qcom/emac: do not reset the EMAC during
 initialization
Date: Fri, 23 Jun 2017 13:37:58 -0500
Message-ID: <b0bbdab5-7c3d-b02e-3e69-a0cb4e214ef2@codeaurora.org>
References: <1498154732-19854-1-git-send-email-timur@codeaurora.org>
 <1498154732-19854-3-git-send-email-timur@codeaurora.org>
 <20170623.140031.865751442887165393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51832 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754327AbdFWSiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:38:00 -0400
In-Reply-To: <20170623.140031.865751442887165393.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2017 01:00 PM, David Miller wrote:
> What if the boot loader or something else left the chip in
> a weird state?

We depend on the boot loader leaving the NIC in a very specific state 
already, otherwise the driver can't initialize the hardware.  The 
firmware has to pre-initialize the EMAC for us.

Not only that, but the driver was resetting the MAC *after* programming 
the clocks (on non-ACPI systems) and initializing both PHYs.

> I'm not applying this.
> 
> If it's correct, the explanation in this commit message need
> to be imporved.  The change must be better justified.

Since this is for ACPI systems, I could do this:

	if (!has_acpi_companion(&pdev->dev))
		emac_mac_reset(adpt);

But at the very least, the call should be moved to earlier in the function.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
