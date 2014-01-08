From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and
 protect forwarding path against pmtu spoofing
Date: Tue, 07 Jan 2014 19:13:14 -0500 (EST)
Message-ID: <20140107.191314.881648861654097224.davem@davemloft.net>
References: <20140106084827.GA5766@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515AbaAHANU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 19:13:20 -0500
In-Reply-To: <20140106084827.GA5766@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 6 Jan 2014 09:48:27 +0100

> +ip_forward_use_pmtu - BOOLEAN
> +	By default we don't trust protocol path MTUs while forwarding
> +	because they could be easily forged and can lead to unwanted
> +	fragmentation by the router.
> +	You only need to enable this if you have user-space software
> +	which tries to discover path mtus by itself and depends on the
> +	kernel honoring this information. This is normally not the
> +	case.
> +	Default: 0 (disabled)
> +	Possible values:
> +	0 - disabled
> +	1 - enabled

You made this default to off, great, but the description text still says
that we don't trust PMTU information by default :-)

> +static inline unsigned int ip_dst_mtu_secure(const struct dst_entry *dst,

Please do me a favor and remove the "_secure" bit from this helper function
name.  This function doesn't implicitly do anything "secure", rather it
simply calculates the dst's mtu based upon various conditions.

Thanks.
