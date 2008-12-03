From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 09/39] wimax: provides user space with information needed when opening a WiMAX device
Date: Tue, 2 Dec 2008 18:06:33 -0800
Message-ID: <200812021806.33614.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <61e0e60ace9f0c441b51e5009d304229c4b234d3.1227691434.git.inaky@linux.intel.com> <1227779589.3809.41.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:5961 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753385AbYLCCL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:29 -0500
In-Reply-To: <1227779589.3809.41.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> > When user space wants to open a handle to a WiMAX device, it needs
> > information that is provided as a response to an "open" generic
> > netlink message.
>
> Why is this called "open" when it's not actually any opening that would
> be bracketed with "close"? It seems more like "get info" to me?

The naming is a remnant from when I didn't really understand genl
and there was actually a close; then it got reused to do the discovery
part, but now I am going to kill all that using the iw code you pointed 
me to as a guide.

> > +	result = -ENOMEM;
> > +static
> > +int wimax_gnl_doit_open(struct sk_buff *skb, struct genl_info *info)
> > +{
> > +	int result;
> > +	struct wimax_dev *wimax_dev;
> > +
> > +	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
> > +	result = -EPERM;
> > +	if (security_netlink_recv(skb, CAP_NET_ADMIN))
> > +		goto error_perm;
>
> Ehm, you can do that check by adding the flag below...

This was another consequence (as mentioned somewhere else) of me
not knowning how to use libnl properly; with that fixed, this is not
needed now and it is done with GENL_ADMIN_PERM in the policy flags.

Thanks,

-- 
Inaky

