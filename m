From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] 3c59x: avoid panic in boomerang_start_xmit when
 finding page address:
Date: Wed, 03 Sep 2014 20:58:39 -0700 (PDT)
Message-ID: <20140903.205839.970971614125053614.davem@davemloft.net>
References: <1409676715-2291-1-git-send-email-nhorman@tuxdriver.com>
	<1409739445-28021-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756624AbaIDD5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 23:57:37 -0400
In-Reply-To: <1409739445-28021-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed,  3 Sep 2014 06:17:25 -0400

> This bug was reported on a very old kernel (RHEL6, 2.6.32-491.el6):
...
> v2) Converted PCI_DMA_TODEVICE to DMA_TO_DEVICE.  Thanks Dave!

Ummm, it's still PCI_DMA_TODEVICE.

> -					cpu_to_le32(pci_map_single(
> -						VORTEX_PCI(vp),
> -						(void *)skb_frag_address(frag),
> -						skb_frag_size(frag), PCI_DMA_TODEVICE));
> +					cpu_to_le32(skb_frag_dma_map(
> +						&VORTEX_PCI(vp)->dev,
> +						frag,
> +						frag->page_offset, frag->size, PCI_DMA_TODEVICE));
