From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 07/11] tg3: Add support for link flap avoidance
Date: Tue, 09 Apr 2013 15:15:40 -0400 (EDT)
Message-ID: <20130409.151540.1097356797775302170.davem@davemloft.net>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
	<1365533291-5672-8-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935459Ab3DITPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 15:15:42 -0400
In-Reply-To: <1365533291-5672-8-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Tue, 9 Apr 2013 11:48:07 -0700

> This patch and the following two patches add support for link flap avoidance
> by maintaining the link on power down. This feature is required for
> management capable devices to have the management connection
> uninterrupted on driver reload, reboot and interface up/down.
> 
> The other pros of this feature are
>  - It speeds up boot up time by several seconds as DHCP addresses can be
>    acquired faster.
>  - It avoids lengthy Spanning Tree delay.
> 
> On powerup the hardware brings up the phy with default settings. If the
> link is not up, the management software configures the phy to gigabit
> and starts autonegotiate. Subsequently, as long as the link is up, the
> driver and management refrain from resetting and/or changing any
> configuration that the link depends on.
> 
> The LNK_FLAP_AVOID setting is an NVRAM user configurable bit and is
> disabled by default.  If this setting is enabled, we skip powering down
> the phy and resetting it.
> 
> A second NVRAM setting is 1G_ON_VAUX_OK (off by default). This adds
> support for gigabit link speed when device is on auxiliary power.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks good, all applied, thanks.

If we force a PHY reset due to EEE changes, will the ASF traffic
disruption warning message be emitted?
