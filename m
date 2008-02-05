From: Ross Vandegrift <ross@kallisti.us>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 14:25:59 -0500
Message-ID: <20080205192559.GA10573@kallisti.us>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kallisti.us ([67.59.168.233]:34753 "EHLO kallisti.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753356AbYBETml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 14:42:41 -0500
Content-Disposition: inline
In-Reply-To: <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 10:29:28AM -0800, Glenn Griffin wrote:
> > Syncookies are discouraged these days. They disable too many
> > valuable TCP features (window scaling, SACK) and even without them
> > the kernel is usually strong enough to defend against syn floods
> > and systems have much more memory than they used to be.
> >
> > So I don't think it makes much sense to add more code to it, sorry.
> 
> As you say the kernel is usually strong enough to defend against syn flood
> attacks, but what about the situations where it isn't?  As valuable as the TCP
> features are I would give them up if it means I'm able to connect to my sshd
> port when I otherwise would be unable to.  While increased synq sizes, better
> dropping algorithms, and minisocks are a great way to mitigate the attacks and
> in most cases are enough, there are situations where syncookies are nice.
> 
> Regardless, I would say as long as ipv4 has syncookie support it will
> accurately be viewed as a deficiency of ipv6 if it lacks support.  So perhaps
> the discussion should be we whether all the other defenses are enough to
> warrant the removal of syncookie support from ipv4.  That topic may bring in
> more opinions.

Yes, syncookies, while presenting some tradeoffs, are a necessary tool
to have.

The problem is that any reasonably recent PC can generate enough
forged SYN packets to overwhelm reasonable SYN queues on a much more
powerful server.

Imagine a server with a few hundres Apache virtual hosts.  One website
pisses off the wrong person and it impacts service for everyone.
While syncookies isn't always enough, enabling it often helps
make the server more resiliant during attacks.  And for web service, most
of the connections are short-lived connections for small pieces of data -
so I'm not really convinced that window scaling and selective ACK are all
that important.


-- 
Ross Vandegrift
ross@kallisti.us

"The good Christian should beware of mathematicians, and all those who
make empty prophecies. The danger already exists that the mathematicians
have made a covenant with the devil to darken the spirit and to confine
man in the bonds of Hell."
	--St. Augustine, De Genesi ad Litteram, Book II, xviii, 37
