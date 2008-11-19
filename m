From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC PATCH 02/13] extended semantic of sk_buff::tstamp: lowest
	bit marks hardware time stamps
Date: Wed, 19 Nov 2008 13:50:06 +0100
Message-ID: <1227099006.16263.46.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
	 <1226415407.31699.1.camel@ecld0pohly>
	 <20081112.015855.198624869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32864 "EHLO mga02.intel.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752497AbYKSMuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 07:50:10 -0500
In-Reply-To: <20081112.015855.198624869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 09:58 +0000, David Miller wrote:
> From: Patrick Ohly <patrick.ohly@intel.com>
> Date: Wed, 22 Oct 2008 10:17:24 +0200
> 
> > +int skb_hwtstamp_raw(const struct sk_buff *skb, struct timespec *stamp)
> > +{
> > +	struct rtable *rt;
> > +	struct in_device *idev;
> > +	struct net_device *netdev;
> > +
> > +	if (skb_hwtstamp_available(skb) &&
> > +	    (rt = skb->rtable) != NULL &&
> > +	    (idev = rt->idev) != NULL &&
> > +	    (netdev = idev->dev) != NULL  &&
> > +	    netdev->hwtstamp_raw) {
> > +		return netdev->hwtstamp_raw(skb, stamp);
> > +	} else {
> > +		return 0;
> > +	}
> > +}
> > +
> > +EXPORT_SYMBOL_GPL(skb_hwtstamp_raw);
> 
> You can't be accessing the generic destination cache entry attached to
> the SKB, here in generic SKB code, as a pointer to an ipv4 specific
> route object.  What if this is an IPV6 or DECNET packet?

Yes, this is problematic. The revised patch still depends on this
pointer chain, now to convert the raw hardware time stamp to system
time. I don't see any clean solution right now except adding both raw
and transformed value to the skb (16 additional bytes instead of just 8,
or zero as in the original patch).

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

