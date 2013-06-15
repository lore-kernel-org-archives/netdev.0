From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4] ethernet/arc/arc_emac - Add new driver
Date: Sat, 15 Jun 2013 13:37:51 -0700
Message-ID: <1371328671.2117.6.camel@joe-AO722>
References: <1371327652-9368-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371327652-9368-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-06-16 at 00:20 +0400, Alexey Brodkin wrote:
> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
> ARCAngel4/ML50x.

> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
[]
> +		if (DUPLEX_FULL == phy_dev->duplex)

Most all kernel code uses "if (var == constant)"
as that's how most people think.

[]

> +static int arc_emac_rx(struct net_device *ndev, int budget)
[]
> +		/* Prepare the BD for next cycle */
> +		rx_buff->skb = netdev_alloc_skb_ip_align(ndev, buflen);
> +		if (unlikely(!rx_buff->skb)) {
> +			if (net_ratelimit())
> +				netdev_err(ndev, "cannot allocate skb\n");

Unnecessary OOM message, might as well remove it.
rx_dropped gives the same info.
