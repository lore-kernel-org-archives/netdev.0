From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 5/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Tue, 11 Mar 2014 15:59:07 -0700
Message-ID: <1394578747.28839.4.camel@joe-AO722>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
	 <1394577791-6547-6-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1394577791-6547-6-git-send-email-vbridgers2013@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-11 at 17:43 -0500, Vince Bridgers wrote:
> This patch adds miscellaneous files for the Altera Ethernet Driver,
> including ethtool support.

trivial notes:

> diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c
[]
> +static char const stat_gstrings[][ETH_GSTRING_LEN] = {

static const char

> +	"aFramesTransmittedOK",

Why the prefix with a?

> +	"aFramesReceivedOK",

"rx_packets" is typically used

> +	"aFramesCheckSequenceErrors",

> +	"aAlignmentErrors",
> +	"aOctetsTransmittedOK",
> +	"aOctetsReceivedOK",
> +	"aTxPAUSEMACCtrlFrames",
> +	"aRxPAUSEMACCtrlFrames",
> +	"ifInErrors",
> +	"ifOutErrors",
> +	"ifInUcastPkts",
> +	"ifInMulticastPkts",
> +	"ifInBroadcastPkts",
> +	"ifOutDiscards",
> +	"ifOutUcastPkts",
> +	"ifOutMulticastPkts",
> +	"ifOutBroadcastPkts",
> +	"etherStatsDropEvents",
> +	"etherStatsOctets",
> +	"etherStatsPkts",
> +	"etherStatsUndersizePkts",
> +	"etherStatsOversizePkts",
> +	"etherStatsPkts64Octets",
> +	"etherStatsPkts65to127Octets",
> +	"etherStatsPkts128to255Octets",
> +	"etherStatsPkts256to511Octets",
> +	"etherStatsPkts512to1023Octets",
> +	"etherStatsPkts1024to1518Octets",
> +	"etherStatsPkts1519toXOctets",
> +	"etherStatsJabbers",
> +	"etherStatsFragments",

Perhaps review all of these strings for
unusual naming.

> +static void tse_get_regs(struct net_device *dev, struct ethtool_regs *regs,
> +			 void *regbuf)
> +{
> +	int i;
> +	struct altera_tse_private *priv = netdev_priv(dev);
> +	u32 *tse_mac_regs = (u32 *)priv->mac_dev;
> +	u32 *buf = (u32 *)regbuf;

void * doesn't need a cast

	u32 *buf = regbuf

is just fine.



