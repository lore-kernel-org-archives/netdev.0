From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 RFC 5/7] Break KSZ9477 DSA driver into two files
Date: Sat, 14 Oct 2017 21:52:13 +0200
Message-ID: <20171014195213.GM18578@lunn.ch>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-6-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>,
        muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507321985-15097-6-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/dsa/microchip/ksz9477.c b/drivers/net/dsa/microchip/ksz9477.c
> new file mode 100644
> index 0000000..214d380
> --- /dev/null
> +++ b/drivers/net/dsa/microchip/ksz9477.c
> @@ -0,0 +1,1328 @@
> +/*
> + * Microchip KSZ9477 switch driver main logic
> + *
> + * Copyright (C) 2017 Microchip Technology Inc.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/delay.h>
> +#include <linux/export.h>
> +#include <linux/gpio.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/platform_data/microchip-ksz.h>
> +#include <linux/phy.h>
> +#include <linux/etherdevice.h>
> +#include <linux/if_bridge.h>
> +#include <net/dsa.h>
> +#include <net/switchdev.h>
> +
> +#include "ksz_priv.h"
> +#include "ksz_common.h"
> +#include "ksz_9477_reg.h"
> +
> +static const struct {
> +	int index;
> +	char string[ETH_GSTRING_LEN];
> +} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
> +	{ 0x00, "rx_hi" },
> +	{ 0x01, "rx_undersize" },
> +	{ 0x02, "rx_fragments" },
> +	{ 0x03, "rx_oversize" },
> +	{ 0x04, "rx_jabbers" },
> +	{ 0x05, "rx_symbol_err" },
> +	{ 0x06, "rx_crc_err" },
> +	{ 0x07, "rx_align_err" },
> +	{ 0x08, "rx_mac_ctrl" },
> +	{ 0x09, "rx_pause" },
> +	{ 0x0A, "rx_bcast" },
> +	{ 0x0B, "rx_mcast" },
> +	{ 0x0C, "rx_ucast" },
> +	{ 0x0D, "rx_64_or_less" },
> +	{ 0x0E, "rx_65_127" },
> +	{ 0x0F, "rx_128_255" },
> +	{ 0x10, "rx_256_511" },
> +	{ 0x11, "rx_512_1023" },
> +	{ 0x12, "rx_1024_1522" },
> +	{ 0x13, "rx_1523_2000" },
> +	{ 0x14, "rx_2001" },
> +	{ 0x15, "tx_hi" },
> +	{ 0x16, "tx_late_col" },
> +	{ 0x17, "tx_pause" },
> +	{ 0x18, "tx_bcast" },
> +	{ 0x19, "tx_mcast" },
> +	{ 0x1A, "tx_ucast" },
> +	{ 0x1B, "tx_deferred" },
> +	{ 0x1C, "tx_total_col" },
> +	{ 0x1D, "tx_exc_col" },
> +	{ 0x1E, "tx_single_col" },
> +	{ 0x1F, "tx_mult_col" },
> +	{ 0x80, "rx_total" },
> +	{ 0x81, "tx_total" },
> +	{ 0x82, "rx_discards" },
> +	{ 0x83, "tx_discards" },
> +};
> +
> +static void ksz_cfg32(struct ksz_device *dev, u32 addr, u32 bits, bool set)
> +{
> +	u32 data;
> +
> +	ksz_read32(dev, addr, &data);
> +	if (set)
> +		data |= bits;
> +	else
> +		data &= ~bits;
> +	ksz_write32(dev, addr, data);
> +}

In a follow up patch, it would be good to fixup the naming. All
functions should use the ksz9477_ prefix.

But this is O.K. for now.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
