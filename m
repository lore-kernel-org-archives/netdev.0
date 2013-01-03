From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 03 Jan 2013 09:28:25 -0800
Message-ID: <1357234105.4740.10.camel@joe-AO722>
References: <1357232192-32634-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33388 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753443Ab3ACR2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 12:28:30 -0500
In-Reply-To: <1357232192-32634-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 17:56 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
> BCMA is a Broadcom specific bus with devices AKA cores. All recent BC=
MA
> based SoCs have gigabit ethernet provided by the GBit MAC core. This
> patch adds driver for such a cores registering itself as a netdev. It
> has been tested on a BCM4706 and BCM4718 chipsets.

Just some style trivia if you want to clean it up later.

> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
[]
> +		bgmac_err(bgmac, "Timeout suspending DMA TX ring 0x%X (BGMAC_DMA_T=
X_STAT: 0x%08X)\n",
> +			  ring->mmio_base, val);

It'd be nicer if you always used this wrapping style.

[]

> +		bgmac_warn(bgmac, "DMA TX ring 0x%X wasn't disabled on time, waiti=
ng additional 300us\n", ring->mmio_base);

checkpatch wouldn't bleat a long line warning here if it was
written as:

		bgmac_warn(bgmac, "DMA TX ring 0x%X wasn't disabled on time, waiting =
additional 300us\n",
			   ring->mmio_base);

There are maybe a dozen lines like it.


> +			bgmac_err(bgmac, "Hardware reported transmission for empty TX rin=
g slot %d! End of ring: %d", ring->start, ring->end);

Here's one.
This format is also missing "\n" newline termination.

			bgmac_err(bgmac, "Hardware reported transmission for empty TX ring s=
lot %d! End of ring: %d\n",
				  ring->start, ring->end);
