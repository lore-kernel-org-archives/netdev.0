From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
 below 4 GB
Date: Wed, 11 May 2016 19:58:53 -0400 (EDT)
Message-ID: <20160511.195853.1708987256480186664.davem@davemloft.net>
References: <1462952869-23498-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ricardo.salveti@linaro.org,
	leo.duran@amd.com, graeme.gregory@linaro.org, nic_swsd@realtek.com
To: ard.biesheuvel@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbcEKX6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:58:55 -0400
In-Reply-To: <1462952869-23498-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 11 May 2016 09:47:49 +0200

> The current logic around the 'use_dac' module parameter prevents the
> r81969 driver from being loadable on 64-bit systems without any RAM
> below 4 GB when the parameter is left at its default value.
> So introduce a new default value -1 which indicates that 64-bit DMA
> should be enabled implicitly, but only if setting a 32-bit DMA mask
> has failed earlier. This should prevent any regressions like the ones
> caused by previous attempts to change this code.
> 
> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

I think we should just seriously consider changing the default, it's
a really outdated reasoning behind the current default setting.  Maybe
relevant a decade ago, but probably not now.

And if the card is completely disfunctional in said configuration, the
default is definitely wrong.
