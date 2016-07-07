From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC net-next 2/4] sit: support MPLS over IPv4
Date: Wed, 06 Jul 2016 22:10:59 -0700 (PDT)
Message-ID: <20160706.221059.1791526468514384047.davem@davemloft.net>
References: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
	<1467829355-4498-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbcGGFMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:12:19 -0400
In-Reply-To: <1467829355-4498-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Wed,  6 Jul 2016 20:22:33 +0200

>  
> +bool ipip6_valid_ip_proto(u8 ipproto)
> +{
> +	return ipproto == IPPROTO_IPV6 ||
> +		ipproto != IPPROTO_IPIP ||
> +#if IS_ENABLED(CONFIG_MPLS)
> +		ipproto == IPPROTO_MPLS ||
> +#endif
> +		ipproto == 0;
> +}

This returns true any time ipproto is not equal to IPPROTO_IPIP,
which is probably not what you intended here.
