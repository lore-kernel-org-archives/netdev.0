From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHi v2] net: sh_eth: Add support of device tree probe
Date: Fri, 22 Feb 2013 10:49:19 -0800
Message-ID: <20130222184918.GC31345@verge.net.au>
References: <1360803091-26400-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <87mwv7ofgj.wl%kuninori.morimoto.gx@renesas.com>
 <511C5279.3070008@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	netdev@vger.kernel.org, magnus.damm@gmail.com,
	devicetree-discuss@lists.ozlabs.org, kda@linux-powerpc.org
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54839 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755641Ab3BWKAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 05:00:53 -0500
Content-Disposition: inline
In-Reply-To: <511C5279.3070008@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 11:56:57AM +0900, Nobuhiro Iwamatsu wrote:
> (2013/02/14 10:24), Kuninori Morimoto wrote:
> >
> >Hi Iwamatsu-san
> >
> >Thank you for this patch.
> >
> >Small comment from me
> >
> >>+#ifdef CONFIG_OF
> >(snip)
> >>+sh_eth_parse_dt(struct device *dev, struct net_device *ndev)
> >>+{
> >>+	int ret;
> >>+	struct device_node *np = dev->of_node;
> >>+	struct sh_eth_plat_data *pdata;
> >...
> >>+#else
> >>+static struct sh_eth_plat_data *
> >>+sh_eth_parse_dt(struct device *dev, struct net_device *ndev)
> >>+{
> >>+	return NULL;
> >>+}
> >>+#endif
> >
> >(snip)
> >
> >>  static int sh_eth_drv_probe(struct platform_device *pdev)
> >>  {
> >...
> >>+#ifdef CONFIG_OF
> >>+	if (np&&  of_device_is_available(np)) {
> >>+		pd = sh_eth_parse_dt(&pdev->dev, ndev);
> >>+		if (pdev->dev.platform_data) {
> >>+			struct sh_eth_plat_data *tmp =
> >>+				pdev->dev.platform_data;
> >>+			pd->set_mdio_gate = tmp->set_mdio_gate;
> >>+			pd->needs_init = tmp->needs_init;
> >>+		}
> >>+	} else
> >>+#endif
> >
> >sh_eth_parse_dt() was defined for both CONFIG_OF and !CONFIG_OF.
> >But it is called only from CONFIG_OF ?
> >
> 
> Because of_device_is_available needs CONFIG_OF.
> I already send a patch which add empty function of of_device_is_available.
> If this was apply, this ifdef becomes without need.

Hi Iwamatsu-san,

could you let me know of the status of that patch?
Has it been queued-up or merged? If so, where and when?
