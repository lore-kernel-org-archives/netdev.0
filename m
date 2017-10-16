From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 3/5] net: dsa: mv88e6060: setup random mac
 address
Date: Mon, 16 Oct 2017 09:05:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0097993@AcuExch.aculab.com>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
 <20171013181809.14627-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: 'Vivien Didelot' <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013181809.14627-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot
> Sent: 13 October 2017 19:18
> As for mv88e6xxx, setup the switch from within the mv88e6060 driver with
> a random MAC address, and remove the .set_addr implementation.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6060.c | 43 ++++++++++++++++++++++++++-----------------
>  1 file changed, 26 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index d64be2b83d3c..6173be889d95 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
> @@ -9,6 +9,7 @@
>   */
> 
>  #include <linux/delay.h>
> +#include <linux/etherdevice.h>
>  #include <linux/jiffies.h>
>  #include <linux/list.h>
>  #include <linux/module.h>
> @@ -188,6 +189,27 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
>  	return 0;
>  }
> 
> +static int mv88e6060_setup_addr(struct dsa_switch *ds)
> +{
> +	u8 addr[ETH_ALEN];
> +	u16 val;
> +
> +	eth_random_addr(addr);
> +
> +	val = addr[0] << 8 | addr[1];
> +
> +	/* The multicast bit is always transmitted as a zero, so the switch uses
> +	 * bit 8 for "DiffAddr", where 0 means all ports transmit the same SA.
> +	 */
> +	val &= 0xfeff;

The comment is probably ok, but the mask isn't needed.
eth_randmon_addr() won't return and address with the multicast bit set.

	David
