From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v2 6/6] ARM: davinci: da850: configure system configuration
 chip(CFGCHIP3) for emac
Date: Mon, 4 Feb 2013 10:58:46 +0530
Message-ID: <510F470E.5040205@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com> <1359380879-26306-7-git-send-email-prabhakar.lad@ti.com> <510E5BCF.9080006@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Prabhakar Lad <prabhakar.csengg@gmail.com>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	<netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>, Heiko Schocher <hs@denx.de>,
	<linux-arm-kernel@lists.infradead.org>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55346 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab3BDF3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 00:29:05 -0500
In-Reply-To: <510E5BCF.9080006@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/2013 6:15 PM, Sekhar Nori wrote:
> On 1/28/2013 7:17 PM, Prabhakar Lad wrote:
>> From: Lad, Prabhakar <prabhakar.lad@ti.com>

> There are couple of issues with this implementation.
> 
> 1) da8xx_config_emac() is specific to DA850 EVM, but masquerades as
>    generic for da8xx. Looks like you need two functions, one for soc
>    specific configuration and one board specific.
> 2) da8xx_config_emac() goes through all the time, whether the
>    particular board has emac module or not. Shouldn't
>    da8xx_config_emac() check if emac is actually enabled in the passed
>    dtb and only the do the configuration?
> 3) The function assumes mii is used always, you can use the rmii_en dt
>    property to check if rmii/mii is enabled and configure the soc/board
>    accordingly.
> 4) If the same function can work both for da850 and da830, then it can
>    be implemented outside of CONFIG_ARCH_DAVINCI_DA850.

Another thing I forgot to mention:

5) This patch replicates a lot of code form board-da850-evm.c. This
needs to be avoided. May be create function to configure emac in
da850.c. This can then be called in board-da850-evm.c as well as in the
dt case.

Thanks,
Sekhar
