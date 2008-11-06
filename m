From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] ssb: Fix DMA-API compilation for non-PCI systems
Date: Thu, 6 Nov 2008 16:16:00 -0500
Message-ID: <8bd0f97a0811061316u6b9a330dy279cb7dca679ab73@mail.gmail.com>
References: <200811062149.21841.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	"Mike Frysinger" <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:34832 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbYKFVQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 16:16:01 -0500
In-Reply-To: <200811062149.21841.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 6, 2008 at 15:49, Michael Buesch wrote:
> --- wireless-testing.orig/include/linux/ssb/ssb.h       2008-08-01 17:26:05.000000000 +0200
> +++ wireless-testing/include/linux/ssb/ssb.h    2008-11-06 21:45:37.000000000 +0100
> @@ -427,12 +427,16 @@ static inline int ssb_dma_mapping_error(
>  {
>        switch (dev->bus->bustype) {
>        case SSB_BUSTYPE_PCI:
> +#ifdef CONFIG_SSB_PCIHOST
>                return pci_dma_mapping_error(dev->bus->host_pci, addr);
> +#endif
> +               break;
>        case SSB_BUSTYPE_SSB:
>                return dma_mapping_error(dev->dev, addr);
>        default:
> -               __ssb_dma_not_implemented(dev);
> +               break;
>        }

all these functions now read:
default: break;
seems kind of pointless ... why not just drop that case completely

otherwise looks good, thanks
-mike
