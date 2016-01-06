From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Tue, 5 Jan 2016 18:21:38 -0600
Message-ID: <568C5E12.8050100@codeaurora.org>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sdharia@codeaurora.org, shankerd@codeaurora.org,
	gregkh@linuxfoundation.org, vikrams@codeaurora.org,
	cov@codeaurora.org
To: Gilad Avidov <gavidov@codeaurora.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gilad Avidov wrote:

> diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
> new file mode 100644
> index 0000000..36a7746
> --- /dev/null
> +++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
> @@ -0,0 +1,1808 @@
> +/* Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +/* Qualcomm Technologies, Inc. EMAC Ethernet Controller MAC layer support
> + */
> +
> +#include <linux/tcp.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/crc32.h>
> +#include <linux/if_vlan.h>
> +#include <linux/jiffies.h>
> +#include <linux/phy.h>
> +#include <linux/of.h>
> +#include <linux/gpio.h>
> +#include <linux/pm_runtime.h>
> +#include "emac.h"
> +#include "emac-sgmii.h"

You also need

	#include <net/ip6_checksum.h>

otherwise you get this:

   CC      drivers/net/ethernet/qualcomm/emac/emac-mac.o
drivers/net/ethernet/qualcomm/emac/emac-mac.c: In function 'emac_tso_csum':
drivers/net/ethernet/qualcomm/emac/emac-mac.c:2045:4: error: implicit 
declaration of function 'csum_ipv6_magic' 
[-Werror=implicit-function-declaration]
     tcp_hdr(skb)->check = ~csum_ipv6_magic(
     ^
