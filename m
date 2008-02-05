From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 21:02:11 +0100
Message-ID: <20080205200211.GA26150@one.firstfloor.org>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48067 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637AbYBET1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 14:27:19 -0500
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

Have you seen such a case in practice with a modern kernel? 

They also cause problems unfortunately; e.g. there is no real flow control for connections
anymore in the non DOS case.

> Regardless, I would say as long as ipv4 has syncookie support it will
> accurately be viewed as a deficiency of ipv6 if it lacks support.  So perhaps
> the discussion should be we whether all the other defenses are enough to
> warrant the removal of syncookie support from ipv4.  That topic may bring in
> more opinions.

That is essentially what I and Alan were discussing.
> 
> > Besides you should really move it to the ipv6 module, right now the code
> > would be always compiled in even for ipv4 only kernels.
> 
> That is correct.  I will gladly move it into it's own section within net/ipv6/.
> Do you have any problem using the same CONFIG and sysctl variables as the ipv4
> implementation?

No.

-Andi
