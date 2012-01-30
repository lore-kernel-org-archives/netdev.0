From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [07/22] Cyclades PC300 driver: ioctl() fixes for mixed 64/32-bit systems
Date: Mon, 30 Jan 2012 11:44:10 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E3F@saturn3.aculab.com>
References: <20120130024929.GH10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <khc@pm.waw.pl>, <davem@davemloft.net>, <mmarek@suse.cz>,
	<jkosina@suse.cz>, <joe@perches.com>, <justinmattock@gmail.com>,
	<gregkh@suse.de>, <alan@linux.intel.com>, <jdmason@kudzu.us>
To: "Andrea Shepard" <andrea@persephoneslair.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20120130024929.GH10262@cronus.persephoneslair.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> +struct pc300_net_stats {
> +	u64 rx_packets;
...
> +	u64 rx_compressed;
> +	u64 tx_compressed;
> +};
> +
>  typedef struct pc300stats {
>  	int hw_type;
>  	u32 line_on;
>  	u32 line_off;
> -	struct net_device_stats gen_stats;
> +	/* Use this instead of net_device_stats, since passing
> +	 * net_device_stats breaks 32-bit user processes on 
> 64-bit kernels,
> +	 * and rtnetlink is unreasonably complicated just to get
> +	 * some statistics.
> +	 */
> +	struct pc300_net_stats net_stats;
>  	falc_t te_stats;
>  } pc300stats_t;

Since 'struct net_device_stats' looks like a common structure,
maybe the 64bit version should be added in the same place??

...
> +struct pc300hw_user {
> +	int type;               /* RSV, X21, etc. */
> +	int bus;                /* Bus (PCI, PMC, etc.) */
> +	int nchan;              /* number of channels */
> +	int irq;                /* interrupt request level */
> +	u32 clock;              /* Board clock */
> +	u8 cpld_id;             /* CPLD ID (TE only) */
> +	u16 cpld_reg1;          /* CPLD reg 1 (TE only) */

You should probably make all the fields fixed sized types and
ensure there is no implicit padding added between fields.

	David
