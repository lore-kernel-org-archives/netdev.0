From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v3 1/3] sh_eth: add support for gpio reset
Date: Tue, 2 Jul 2013 14:25:00 +0900
Message-ID: <20130702052458.GA23507@verge.net.au>
References: <1372652695-16606-1-git-send-email-horms+renesas@verge.net.au>
 <1372652695-16606-2-git-send-email-horms+renesas@verge.net.au>
 <51D19122.6030409@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51D19122.6030409@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 01, 2013 at 06:24:34PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 01-07-2013 8:24, Simon Horman wrote:
> 
> >Allow reset using a GPIO. In order to use this set the following
> >in the device's platform data:
> 
> >	needs_gpio_reset = 1
> >	reset_gpio = GPIO pin to use
> 
> >This patch is motivated by the lager board which uses the r8a7790 SoC
> >which has a GPIO pin to reset its sh_eth device.
> 
> >Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> 
> >--
> 
> >v2
> >* First post
> >---
> >  drivers/net/ethernet/renesas/sh_eth.c | 4 ++++
> >  include/linux/sh_eth.h                | 3 +++
> >  2 files changed, 7 insertions(+)
> 
> >diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> >index 7732f11..0253f61 100644
> >--- a/drivers/net/ethernet/renesas/sh_eth.c
> >+++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
> >@@ -2652,6 +2653,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> >  		ndev->features = NETIF_F_HW_VLAN_CTAG_FILTER;
> >  	}
> >
> >+	if (pd->needs_gpio_reset)
> >+		gpio_request_one(pd->reset_gpio, GPIOF_OUT_INIT_HIGH, NULL);
> 
>    Is reset signal active low or active high? Are you asserting or
> releasing it?

Good point.

I'm not sure that the documentation that I have is sufficient to answer that.
Empirically it seems that this change isn't strictly necessary, so perhaps
it would be best to drop it for now.

> 
> >diff --git a/include/linux/sh_eth.h b/include/linux/sh_eth.h
> >index fc30571..b3f1550 100644
> >--- a/include/linux/sh_eth.h
> >+++ b/include/linux/sh_eth.h
> >@@ -22,6 +22,9 @@ struct sh_eth_plat_data {
> >  	unsigned no_ether_link:1;
> >  	unsigned ether_link_active_low:1;
> >  	unsigned needs_init:1;
> >+	unsigned needs_gpio_reset:1;
> >+
> >+	unsigned reset_gpio;	/* Used if needs_gpio_reset is true */
> 
>    s/true/1/.
> 
> WBR, Sergei
> 
