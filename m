From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [net-next-2.6 PATCH] wireless: convert to use
	netdev_for_each_mc_addr
Date: Wed, 03 Mar 2010 18:42:56 +0200
Message-ID: <20100303184256.19122kg5hcqolfgg@hayate.sektori.org>
References: <20100303114506.19575pbsu8yz2kjk@hayate.sektori.org>
	<20100303124249.GD2961@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: "Jiri Pirko" <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sypressi.dnainternet.net ([83.102.40.135]:58940 "EHLO
	sypressi.dnainternet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754455Ab0CCQm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 11:42:57 -0500
In-Reply-To: <20100303124249.GD2961@psychotron.lab.eng.brq.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Quoting "Jiri Pirko" <jpirko@redhat.com>:

> +	} else if (mc_count) {
> +		int size = min(priv->multicast_size, mc_count);
> +		int i = 0;
> +
> +		mc_addrs = kmalloc(size * ETH_ALEN, GFP_ATOMIC);
...
> +	if (filter != basefilter)
> +		goto set_filter;
> +
> +	if (mc_count) {
> +		ret = rndis_set_oid(usbdev, OID_802_3_MULTICAST_LIST, mc_addrs,
> +				    mc_count * ETH_ALEN);
> +		kfree(mc_addrs);

mc_addrs was alloced by with 'size * ETH_ALEN', which might be less  
than mc_count * ETH_ALEN.

Otherwise ok, and rndis_wlan works.

  -Jussi

