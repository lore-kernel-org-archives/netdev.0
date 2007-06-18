From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 14:00:05 +0200
Message-ID: <E1I0Ftt-0007Xc-00@dorka.pomaz.szeredi.hu>
References: <E1I0BzQ-0006gZ-00@dorka.pomaz.szeredi.hu>
	<20070618.005711.21897961.davem@davemloft.net>
	<E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu>
	<20070618.021813.105401188.davem@davemloft.net>
	<E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu> <20070618124721.56411b93@the-village.bc.nu>
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	viro@ftp.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1.sa.eol.hu ([212.108.200.67]:52580 "EHLO
	mail-gw1.sa.eol.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761996AbXFRMAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 08:00:50 -0400
In-reply-to: <20070618124721.56411b93@the-village.bc.nu> (message from Alan
	Cox on Mon, 18 Jun 2007 12:47:21 +0100)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > No, correctness always trumps performance.  Lost packets on an AF_UNIX
> > socket are _unexceptable_, and this is definitely not a theoretical
> > problem.
> 
> If its so unacceptable why has nobody noticed until now - its a bug
> clearly, it needs fixing clearly, but unless you can produce some kind of
> exploit from it (eg a DoS attack or kernel memory leak exploiter) it
> doesn't appear to be that serious.

It's serious in that it affects the operation of one of my
applications in a way that is rather hard to work around.  Sure, I
could resend the lost sockets, but it's something one doesn't do
unnecessarily for reliable transports.

And it's entirely possible, that it could bite other apps in rare and
mysterious ways.  All you need is

  - an application that sends a unix socket over a unix socket

  - a parallel close() operation on an independent unix socket

The two might happen to be from totally unrelated apps.

It's all the more serious, because it could happen rarely and
unreproducibly, and could well be crashing the app which is not
expecting this behavior.

> > And BTW my second patch does _not_ have the performance problems you
> > are arguing about, it's just plain ugly.  But hey, if you can't live
> > with ugly code, go and fix it.
> 
> If you put ugly code into the kernel you pay for maintaining it for years
> to come. If you get it right then you don't
> 
> > Do you want me to send the patch to Andrew instead?  His attitude
> > towards bugfixes is rather better ;)
> 
> And it'll get NAKked and binned. DaveM is (as happens sometimes ;)) right
> to insist on the code being clean and efficient.

Right, but treating a bug in your subsystem as if it's entirely the
responsibility of the reporter is not the right attitude either I
think.

Miklos
