From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] net: fix ethtool->set_flags not intended -EINVAL return
 value
Date: Mon, 21 Mar 2011 15:15:06 +0000
Message-ID: <1300720506.2527.1.camel@bwh-desktop>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <4D8385CE.1060205@intel.com>
	 <1300699294.10934.63.camel@firesoul.comx.local>
	 <1300700708.2884.10.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8429@MNEXMB2.qlogic.org>
	 <20110321123406.GA2376@redhat.com> <20110321134647.GA3126@redhat.com>
	 <1300715543.26693.349.camel@localhost>  <20110321151015.GA2209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36271 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab1CUPPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 11:15:10 -0400
In-Reply-To: <20110321151015.GA2209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-21 at 16:10 +0100, Stanislaw Gruszka wrote:
> After commit d5dbda23804156ae6f35025ade5307a49d1db6d7 "ethtool: Add
> support for vlan accleration.", drivers that have NETIF_F_HW_VLAN_TX,
> and/or NETIF_F_HW_VLAN_RX feature, but do not allow enable/disable vlan
> acceleration via ethtool set_flags, always return -EINVAL from that
> function. Fix by returning -EINVAL only if requested features do
> not match current settings and can not be changed by driver.
> 
> RFC for now, compile tested only.

This looks good, but:

[...]
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index c1a71bb..514127d 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -141,9 +141,17 @@ u32 ethtool_op_get_flags(struct net_device *dev)
>  }
>  EXPORT_SYMBOL(ethtool_op_get_flags);
>  
> +bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported)
> +{
> +	u32 features = dev->features & flags_dup_features;
> +
> +	return ((features & ~supported) != (data & ~supported));
> +}
> +EXPORT_SYMBOL(ethtool_invalid_flags);
[...]

This needs a comment.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

