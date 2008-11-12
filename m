From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 02/13] extended semantic of sk_buff::tstamp: lowest
 bit marks hardware time stamps
Date: Wed, 12 Nov 2008 01:58:55 -0800 (PST)
Message-ID: <20081112.015855.198624869.davem@davemloft.net>
References: <1226414697.17450.852.camel@ecld0pohly>
	<1226415407.31699.1.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com,
	shemminger@vyatta.com, netdev@axxeo.de, ak@linux.intel.com,
	john.ronciak@intel.com, dada1@cosmosbay.com, oliver@hartkopp.net
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751291AbYKLJ64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 04:58:56 -0500
In-Reply-To: <1226415407.31699.1.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Wed, 22 Oct 2008 10:17:24 +0200

> +int skb_hwtstamp_raw(const struct sk_buff *skb, struct timespec *stamp)
> +{
> +	struct rtable *rt;
> +	struct in_device *idev;
> +	struct net_device *netdev;
> +
> +	if (skb_hwtstamp_available(skb) &&
> +	    (rt = skb->rtable) != NULL &&
> +	    (idev = rt->idev) != NULL &&
> +	    (netdev = idev->dev) != NULL  &&
> +	    netdev->hwtstamp_raw) {
> +		return netdev->hwtstamp_raw(skb, stamp);
> +	} else {
> +		return 0;
> +	}
> +}
> +
> +EXPORT_SYMBOL_GPL(skb_hwtstamp_raw);

You can't be accessing the generic destination cache entry attached to
the SKB, here in generic SKB code, as a pointer to an ipv4 specific
route object.  What if this is an IPV6 or DECNET packet?
