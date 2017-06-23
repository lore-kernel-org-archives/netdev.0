From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: qcom/emac: do not reset the EMAC during
 initialization
Date: Fri, 23 Jun 2017 14:54:23 -0400 (EDT)
Message-ID: <20170623.145423.192194307144112349.davem@davemloft.net>
References: <1498154732-19854-3-git-send-email-timur@codeaurora.org>
        <20170623.140031.865751442887165393.davem@davemloft.net>
        <b0bbdab5-7c3d-b02e-3e69-a0cb4e214ef2@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754706AbdFWSyY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:54:24 -0400
In-Reply-To: <b0bbdab5-7c3d-b02e-3e69-a0cb4e214ef2@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Fri, 23 Jun 2017 13:37:58 -0500

> On 06/23/2017 01:00 PM, David Miller wrote:
>> What if the boot loader or something else left the chip in
>> a weird state?
> 
> We depend on the boot loader leaving the NIC in a very specific state
> already, otherwise the driver can't initialize the hardware.  The
> firmware has to pre-initialize the EMAC for us.
> 
> Not only that, but the driver was resetting the MAC *after*
> programming the clocks (on non-ACPI systems) and initializing both
> PHYs.
> 
>> I'm not applying this.
>> If it's correct, the explanation in this commit message need
>> to be imporved.  The change must be better justified.
> 
> Since this is for ACPI systems, I could do this:
> 
> 	if (!has_acpi_companion(&pdev->dev))
> 		emac_mac_reset(adpt);
> 
> But at the very least, the call should be moved to earlier in the
> function.

Please just explain the ACPI situation in the commit log message
and resubmit the series.

Thanks.
