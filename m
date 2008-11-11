From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC PATCH 04/13] net: implement generic SOF_TIMESTAMPING_TX_* support
Date: Wed, 12 Nov 2008 01:15:08 +0200
Message-ID: <200811120115.09330.opurdila@ixiacom.com>
References: <1226414697.17450.852.camel@ecld0pohly> <1226415417.31699.3.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:30181 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751155AbYKKXTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 18:19:18 -0500
In-Reply-To: <1226415417.31699.3.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Fri, 24 Oct 2008 15:41:34 +0200


> +	if (dev) {
> +		skb_hwtstamp_set(skb,
> +				dev->hwtstamp_raw2sys ?
> +				dev->hwtstamp_raw2sys(dev, stamp) :
> +				stamp);
> +	} else {
> +		skb->tstamp = stamp;
> +#if BITS_PER_LONG != 64 && !defined(CONFIG_KTIME_SCALAR)
> +		skb->tstamp.tv.sec = skb->tstamp.tv.sec / 2 * 2;
> +#else
> +		skb->tstamp.tv64 = skb->tstamp.tv64 / 2 * 2;
> +#endif
> +	}
> +

I think the addition of the following bits will be of use to applications: 

        serr = SKB_EXT_ERR(skb);
        serr->ee.ee_origin = SO_EE_ORIGIN_TXTSTAMP;
        serr->ee.ee_mac = skb->mac.raw - skb->data;
        serr->ee.ee_network = skb->nh.raw - skb->data;
        serr->ee.ee_transport = skb->h.raw - skb->data;

For example, for UDP PTP we don't have to manually skip the ethernet (and take 
into account VLANs) and IP headers.

Thanks,
tavi

