From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 07/11] net: dsa: debugfs: add port fdb
Date: Tue, 15 Aug 2017 10:35:51 -0700
Message-ID: <1a72a0f3-c461-1099-1309-9604a990057c@gmail.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-8-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/14/2017 03:22 PM, Vivien Didelot wrote:
> Add a debug filesystem "fdb" entry to query a port's hardware FDB
> entries through the .port_fdb_dump switch operation.
> 
> This is really convenient to query directly the hardware or inspect DSA
> or CPU links, since these ports are not exposed to userspace.
> 
>     # cat port1/fdb
>     vid 0    12:34:56:78:90:ab    static    unicast
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/debugfs.c | 36 ++++++++++++++++++++++++++++++++++++
>  1 file changed, 36 insertions(+)
> 
> diff --git a/net/dsa/debugfs.c b/net/dsa/debugfs.c
> index 012fcf466cc1..8204c62dc9c1 100644
> --- a/net/dsa/debugfs.c
> +++ b/net/dsa/debugfs.c
> @@ -10,6 +10,7 @@
>   */
>  
>  #include <linux/debugfs.h>
> +#include <linux/etherdevice.h>
>  #include <linux/seq_file.h>
>  
>  #include "dsa_priv.h"
> @@ -109,6 +110,36 @@ static int dsa_debugfs_create_file(struct dsa_switch *ds, struct dentry *dir,
>  	return 0;
>  }
>  
> +static int dsa_debugfs_fdb_dump_cb(const unsigned char *addr, u16 vid,
> +				   bool is_static, void *data)
> +{
> +	struct seq_file *seq = data;
> +	int i;

unsigned int i?

> +
> +	seq_printf(seq, "vid %d", vid);
> +	for (i = 0; i < ETH_ALEN; i++)
> +		seq_printf(seq, "%s%02x", i ? ":" : "    ", addr[i]);

Too bad we can use %pM here, or can we?

Other than that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
