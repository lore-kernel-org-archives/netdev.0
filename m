From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 10:10:59 -0500
Message-ID: <5773E503.3070404@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <4312386.60Y44nCzSI@wuerfel> <5773DC52.4010703@codeaurora.org>
 <5679359.84lXZytcOR@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com, catalin.marinas@arm.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36477 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbcF2PU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 11:20:57 -0400
In-Reply-To: <5679359.84lXZytcOR@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> That's also not how it works: each device starts out with a 32-bit mask,
> because that's what historically all PCI devices can do. If a device
> is 64-bit DMA capable, it can extend the mask by passing DMA_BIT_MASK(64)
> (or whatever it can support), and the platform code checks if that's
> possible.

So if it's not possible, then dma_set_mask returns an error, and the 
driver should try a smaller mask?  Doesn't that mean that every driver 
for a 64-bit device should do this:

	for (i = 64; i >=32; i--) {
		ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(i));
		if (!ret)
			break;
	}

	if (ret)
		return ret;

Sure, this is overkill, but it seems to me that the driver does not 
really know what mask is actually valid, so it has to find the largest 
mask that works.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
