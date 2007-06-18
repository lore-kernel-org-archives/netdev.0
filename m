From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 11:44:07 +0200
Message-ID: <E1I0DmJ-0006yg-00@dorka.pomaz.szeredi.hu>
References: <E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu>
	<20070618.021813.105401188.davem@davemloft.net>
	<E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu> <20070618.023520.102546505.davem@davemloft.net>
Cc: akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2.sa.eol.hu ([212.108.200.109]:41172 "EHLO
	mail-gw2.sa.eol.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbXFRJo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 05:44:57 -0400
In-reply-to: <20070618.023520.102546505.davem@davemloft.net> (message from
	David Miller on Mon, 18 Jun 2007 02:35:20 -0700 (PDT))
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > > And is anyone working on a better patch?
> > > 
> > > I have no idea.
> > > 
> > > > Those patches aren't "bad" in the correctness sense.  So IMO any one
> > > > of them is better, than having that bug in there.
> > > 
> > > You're adding a very serious performance regression, which is
> > > about as bad as the bug itself.
> > 
> > No, correctness always trumps performance.
> 
> To a point.  There is no black and white in this world.
> 
> > Lost packets on an AF_UNIX socket are _unexceptable_, and this is
> > definitely not a theoretical problem.
> 
> A lot of people will consider having all of their AF_UNIX sockets on
> their 64 cpu system just stop when garbage collection runs to be
> unacceptable as well.

Garbage collection only ever happens, if the app is sending AF_UNIX
sockets over AF_UNIX sockets.  Which is a rather rare case.  And which
is basically why this bug went unnoticed for so long.

So my second patch only affects the performance of _exactly_ those
apps which might well be bitten by the bug itself.

> Secondarily, this bug has been around for years and nobody noticed.
> The world will not explode if this bug takes a few more days or
> even a week to work out.  Let's do it right instead of ramming
> arbitrary turds into the kernel.

Fine, but just wishing a bug to get fixed won't accomplish anything.
I've spent a fair amount of time debugging this thing, and I'm out of
ideas.  Really.  So unless somebody steps up to look at this, it won't
_ever_ get fixed.

Miklos
