From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 5/5] openvswitch: Interface with NAT.
Date: Thu, 22 Oct 2015 01:30:59 +0200
Message-ID: <20151021233059.GE23554@pox.localdomain>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
 <1445379629-112880-5-git-send-email-jrajahalme@nicira.com>
 <20151021105916.GB15766@pox.localdomain>
 <FB21AAF8-5C91-41C8-96DC-E5EE0C02CFE4@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35406 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbbJUXbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 19:31:01 -0400
Received: by wicll6 with SMTP id ll6so112295964wic.0
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 16:31:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <FB21AAF8-5C91-41C8-96DC-E5EE0C02CFE4@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/15 at 02:04pm, Jarno Rajahalme wrote:
> 
> > On Oct 21, 2015, at 3:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > Simplify this with an OVS_NAT_ATTR_FLAGS?
> 
> The use of separate flag attributes was actually intentional, as it makes the interface easier to understand, and code also easier to read.

OK, either is fine with me.

> >> +					  &ctinfo);
> >> +	if (!ct || nf_ct_is_untracked(ct))
> >> +		/* A NAT action may only be performed on tracked packets. */
> >> +		return NF_ACCEPT;
> > 
> > Braces
> > 
> 
> Needed due to the comment?

The compiler would be fine but most other places like this seem to
put braces on for this single comment + single statement case.

> >> +		if (type > OVS_NAT_ATTR_MAX) {
> >> +			OVS_NLERR(log, "Unknown nat attribute (type=%d, max=%d).\n",
> >> +			type, OVS_NAT_ATTR_MAX);
> > 
> > Formatting
> 
> Not readily apparent what you mean here, care to elaborate?

The argument list should be indented up to the (.

> >> +#ifdef CONFIG_NF_NAT_NEEDED
> >> +	[OVS_CT_ATTR_NAT]	= { .minlen = 0,
> >> +				    .maxlen = 96 }
> >> +#endif
> > 
> > Is the 96 a temporary hack here?
> > 
> 
> It is not an exact value. It is much better than my temporary hack of 512 was. As trailing garbage is checked for, I???m not sure if this should be very accurately calculated? Maybe it would be better to disable the length checks for this altogether?

I would just drop the maxlen then. The nested content should be
verified separately anyway later on.

> > We should probably bark if user space provides a OVS_CT_ATTR_NAT but the
> > kernel is compiled without support for it.
> > 
> 
> We do issue -EINVAL and log ???Unknown conntrack attr??? in that case.

Misread then, sorry.
