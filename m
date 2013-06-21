From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v7] ethernet/arc/arc_emac - Add new driver
Date: Fri, 21 Jun 2013 03:32:55 -0700
Message-ID: <1371810775.19215.30.camel@joe-AO722>
References: <1371799241-27771-1-git-send-email-abrodkin@synopsys.com>
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
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Florian Fainelli <florian@openwrt.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371799241-27771-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-21 at 11:20 +0400, Alexey Brodkin wrote:
> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
> ARCAngel4/ML50x.

Looks fine to me.

One nit you could fix later and a question.

> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
[]
> +static int arc_emac_rx(struct net_device *ndev, int budget)
> +{
[]
> +			if (net_ratelimit())
> +				netdev_err(ndev, "incomplete packed received\n");

s/packed/packet/

> +		rxbd->data = (unsigned char *)cpu_to_le32(rx_buff->skb->data);

32 bit only.  Should the Kconfig block have some arch_arc dependency
so it can't get compiled for 64 bit systems?
