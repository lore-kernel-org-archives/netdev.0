From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Sun, 5 Oct 2008 09:28:23 +0200
Message-ID: <20081005092823.1b7b88f8@speedy>
References: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au>
	<20081005065509.GA2538@ami.dom.local>
	<20081005065648.GA13113@gondor.apana.org.au>
	<20081005071238.GA2752@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Benjamin Thery <benjamin.thery@bull.net>, davem@davemloft.net,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35546 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451AbYJEH2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2008 03:28:31 -0400
In-Reply-To: <20081005071238.GA2752@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 5 Oct 2008 09:12:38 +0200
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Sun, Oct 05, 2008 at 02:56:48PM +0800, Herbert Xu wrote:
> > On Sun, Oct 05, 2008 at 08:55:10AM +0200, Jarek Poplawski wrote:
> > >
> > > > -	/* Not safe to do outside the semaphore.  We must not return
> > > > -	 * until all unregister events invoked by the local processor
> > > > -	 * have been completed (either by this todo run, or one on
> > > > -	 * another cpu).
> > > > -	 */
> > > 
> > > I think, it's about not to let others run this for devices unregistered
> > > within later rtnl_locks before completing previous tasks. So, it would
> > > be nice to have some comment why it's not necessary anymore.
> > 
> > Where did you get that idea?
> 
> Just reading this code (plus the comment). Why would anybody bother 
> with something so complex like this if something like your idea is
> rather straightforward? But, needed or not, my point is it would be
> nice to comment that this patch changes this behavior btw.

I think there were issues with unregister triggering hotplug udev
events, but that may have been long ago when rtnl_lock was
a semaphore not a mutex.
