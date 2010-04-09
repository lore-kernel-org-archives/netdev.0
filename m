From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] igb: add support for reporting 5GT/s
 during probe on PCIe Gen2
Date: Sat, 10 Apr 2010 00:54:16 +0100
Message-ID: <1270857256.2176.37.camel@localhost>
References: <20100409195246.30654.40319.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:19900 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754068Ab0DIXyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 19:54:25 -0400
In-Reply-To: <20100409195246.30654.40319.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-09 at 12:52 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change corrects the fact that we were not reporting Gen2 link speeds
> when we were in fact connected at Gen2 rates.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/igb/e1000_defines.h |    3 +++
>  drivers/net/igb/e1000_mac.c     |   19 ++++++++++++++++---
>  drivers/net/igb/igb_main.c      |    1 +
>  3 files changed, 20 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
> index 31d24e0..8e440e8 100644
> --- a/drivers/net/igb/e1000_defines.h
> +++ b/drivers/net/igb/e1000_defines.h
> @@ -615,6 +615,9 @@
>  
>  #define PCIE_LINK_WIDTH_MASK         0x3F0
>  #define PCIE_LINK_WIDTH_SHIFT        4
> +#define PCIE_LINK_SPEED_MASK         0x0F
> +#define PCIE_LINK_SPEED_2500         0x01
> +#define PCIE_LINK_SPEED_5000         0x02
>  #define PCIE_DEVICE_CONTROL2_16ms    0x0005
[...]

These generic definitions belong in <linux/pci_regs.h>; in fact some of
it is already there.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

