From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH 1/2] alchemy: add au1000-eth platform device
Date: Tue, 18 Aug 2009 18:56:37 +0400
Message-ID: <4A8AC125.3020602@ru.mvista.com>
References: <200908170105.38154.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	Manuel Lauss <manuel.lauss@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:48204 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751217AbZHROzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 10:55:14 -0400
In-Reply-To: <200908170105.38154.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Florian Fainelli wrote:

> This patch adds the board code to register a per-board au1000-eth
> platform device to be used wit the au1000-eth platform driver in a
> subsequent patch. Note that the au1000-eth driver knows about the
> default driver settings such that we do not need to pass any
> platform_data informations in most cases except db1x00.

    Sigh, NAK...
    Please don't register the SoC device per board, do it in 
alchemy/common/platfrom.c and find a way to pass the board specific platform 
data from the board file there instead -- something like 
arch/arm/mach-davinci/usb.c does.

> Signed-off-by: Florian Fainelli <florian@openwrt.org>

[...]

> diff --git a/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h b/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
> new file mode 100644
> index 0000000..6d1543e
> --- /dev/null
> +++ b/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
> @@ -0,0 +1,33 @@
> +#ifndef __AU1X00_ETH_DATA_H
> +#define __AU1X00_ETH_DATA_H
> +
> +/* Macro to help defining the Ethernet MAC resources */
> +#define MAC_RES(_base, _enable, _irq)			\
> +	{						\
> +		.start	= CPHYSADDR(_base),		\
> +		.end	= CPHYSADDR(_base + 0xffff),	\
> +		.flags	= IORESOURCE_MEM,		\
> +	},						\
> +	{						\
> +		.start	= CPHYSADDR(_enable),		\
> +		.end	= CPHYSADDR(_enable + 0x4),	\

    s/4/3/.

WBR, Sergei
