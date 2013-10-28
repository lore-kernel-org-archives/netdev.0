From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 00:48:42 +0100
Message-ID: <20131028234842.GB26185@order.stressinduktion.org>
References: <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com> <20131027132941.GA1443@minipsycho.orion> <20131027164835.GB4714@order.stressinduktion.org> <20131028.171725.1076499130782328273.davem@davemloft.net> <1383002179.28991.14.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	vyasevich@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34881 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757788Ab3J1Xso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 19:48:44 -0400
Content-Disposition: inline
In-Reply-To: <1383002179.28991.14.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 06:16:19PM -0500, Dan Williams wrote:
> On Mon, 2013-10-28 at 17:17 -0400, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Sun, 27 Oct 2013 17:48:35 +0100
> > 
> > > A temporary address is also bound to a non-privacy public address so
> > > it's lifetime is determined by its lifetime (e.g. if you switch the
> > > network and don't receive on-link information for that prefix any
> > > more). NetworkManager would have to take care about that, too. It is
> > > just a question of what NetworkManager wants to handle itself or lets
> > > the kernel handle for it.
> > 
> > How much really needs to be in userspace to implement RFC4941?
> > 
> > I don't like the idea that even for a fully up and properly
> > functioning link, if NetworkManager wedges then critical things like
> > temporary address (re-)generation, will cease.
> 
> Honestly, I'd be completely happy to leave temporary address handling up
> to the kernel and *not* do it in userspace; the kernel already has all
> the code.  There are two problems with that though, (a) it's tied to
> in-kernel RA handling, and (b) it's controlled by a CONFIG option.  Both
> these are solvable.

Ah, (a) does complicate things, I agree. But the tieing is essential
currently. So it seems a netlink interface would be needed to tie a new
address to an already installed one, if the kernel should still deal
with the regeneration?

> First off, what's the reasoning behind having IPv6 privacy as a config
> option?  It's off-by-default and must be explicitly turned on, so is
> there any harm in removing the config?  Or is it just for
> smallest-kernel-ever folks?

I don't know about the policy. Does it really matter as distributions
normally switch it on? But I would not like to see the option removed
entirly, maybe the default could be changed.

> Would a new IFA_F_MANAGE_TEMP (or better name) work here, indicating
> that for some new static address, that the kernel should create and
> manage the temporary privacy addresses associated with its prefix?

But this would only be needed if they were managed in user-space, no?

Greetings,

  Hannes
