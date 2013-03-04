From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCHi v2] net: sh_eth: Add support of device tree probe
Date: Mon, 04 Mar 2013 16:05:09 +0800
Message-ID: <20130304080509.EDF323E206B@localhost>
References: <1360803091-26400-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <87mwv7ofgj.wl%kuninori.morimoto.gx@renesas.com> <511C5279.3070008@renesas.com>
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	magnus.damm@gmail.com, kda@linux-powerpc.org,
	horms+renesas@verge.net.au
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:61426 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024Ab3CDIFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 03:05:14 -0500
Received: by mail-da0-f53.google.com with SMTP id n34so2404320dal.40
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 00:05:14 -0800 (PST)
In-Reply-To: <511C5279.3070008@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Feb 2013 11:56:57 +0900, Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com> wrote:
> (2013/02/14 10:24), Kuninori Morimoto wrote:
> >> +#ifdef CONFIG_OF
> >> +	if (np&&  of_device_is_available(np)) {
> >> +		pd = sh_eth_parse_dt(&pdev->dev, ndev);
> >> +		if (pdev->dev.platform_data) {
> >> +			struct sh_eth_plat_data *tmp =
> >> +				pdev->dev.platform_data;
> >> +			pd->set_mdio_gate = tmp->set_mdio_gate;
> >> +			pd->needs_init = tmp->needs_init;
> >> +		}
> >> +	} else
> >> +#endif
> >
> > sh_eth_parse_dt() was defined for both CONFIG_OF and !CONFIG_OF.
> > But it is called only from CONFIG_OF ?
> >
> 
> Because of_device_is_available needs CONFIG_OF.
> I already send a patch which add empty function of of_device_is_available.
> If this was apply, this ifdef becomes without need.

Actually, there shouldn't be any reason for a device driver to call
of_device_is_available() on its own node at all. If the device is not
available, then a platform_device won't be created. "if (np)" here is
sufficient.

g.
