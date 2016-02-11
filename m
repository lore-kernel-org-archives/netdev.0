From: Huw Davies <huw@codeweavers.com>
Subject: Re: [RFC PATCH v2 08/18] ipv6: Add ipv6_renew_options_kern() that
 accepts a kernel mem pointer.
Date: Thu, 11 Feb 2016 14:52:34 +0000
Message-ID: <20160211145233.GA31695@merlot>
References: <1452246774-13241-9-git-send-email-huw@codeweavers.com>
 <2213519.F62jx6DkRd@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:46903 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbcBKOwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 09:52:39 -0500
Content-Disposition: inline
In-Reply-To: <2213519.F62jx6DkRd@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 07, 2016 at 02:56:05PM -0500, Paul Moore wrote:
> On Friday, January 08, 2016 09:52:44 AM Huw Davies wrote:
> > The functionality is equivalent to ipv6_renew_options() except
> > that the newopt pointer is in kernel, not user, memory
> > 
> > The kernel memory implementation will be used by the CALIPSO network
> > labelling engine, which needs to be able to set IPv6 hop-by-hop
> > options.
> > 
> > Signed-off-by: Huw Davies <huw@codeweavers.com>
> 
> ...
> 
> > +/**
> > + * ipv6_renew_options_kern - replace a specific ext hdr with a new one.
> > + *
> > + * @sk: sock from which to allocate memory
> > + * @opt: original options
> > + * @newtype: option type to replace in @opt
> > + * @newopt: new option of type @newtype to replace (kernel-mem)
> > + * @newoptlen: length of @newopt
> > + *
> > + * See ipv6_renew_options().  The difference is that @newopt is
> > + * kernel memory, rather than user memory.
> > + */
> > +struct ipv6_txoptions *
> > +ipv6_renew_options_kern(struct sock *sk, struct ipv6_txoptions *opt,
> > +			int newtype, struct ipv6_opt_hdr *newopt,
> > +			int newoptlen)
> > +{
> > +	struct ipv6_txoptions *ret_val;
> > +	const mm_segment_t old_fs = get_fs();
> > +
> > +	set_fs(KERNEL_DS);
> > +	ret_val = ipv6_renew_options(sk, opt, newtype,
> > +				     (struct ipv6_opt_hdr __user *)newopt,
> > +				     newoptlen);
> > +	set_fs(old_fs);
> > +	return ret_val;
> > +}
> 
> I should preface this by saying that I don't have a strong opinion on this 
> either way, and given where the code lives it is really up to DaveM, but I 
> wonder if it might be better to create ipv6_renew_options_kern() as the common 
> helper function that is called by ipv6_renew_options().

Ok, I'll leave this as it as for v3, and the network guys can shout if
they want me to change it.

Huw.
