From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.20] kobject net ifindex + rename
Date: Thu, 1 Mar 2007 11:27:34 -0800
Message-ID: <20070301192734.GB9098@bougret.hpl.hp.com>
References: <20070228012741.GA3988@bougret.hpl.hp.com> <20070228093437.GA1847@ff.dom.local> <20070228184541.GD6134@bougret.hpl.hp.com> <20070301074209.GA1735@ff.dom.local>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:62220 "EHLO
	gundega.hpl.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965524AbXCAT2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 14:28:14 -0500
Content-Disposition: inline
In-Reply-To: <20070301074209.GA1735@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2007 at 08:42:09AM +0100, Jarek Poplawski wrote:
> On Wed, Feb 28, 2007 at 10:45:41AM -0800, Jean Tourrilhes wrote:
> > > > +
> > > > +	if ((size <= 0) || (i >= num_envp))
> > > 
> > > Btw.:
> > > 1. if size == 10 and snprintf returns 9 (without NULL)
> > >    then n == 10 (with NULL), so isn't it enough (here and above):
> > >  
> > > 	if ((size < 0) || (i >= num_envp))
> > 
> > 	I just cut'n'pasted the code a few line above. If the original
> > code is incorrect, it need fixing. And it will need fixing in probably
> > a lot of places.
> 
> I think you're kind of responsible for your part, at least.

	I personally don't go fixing stuff without having a full
undersunding of the context and why it was done this way. To me it
look this test was intentionally done this way, so there may be
something I don't know about. I guess I would need to double check
more closely what weid calculation the caller does with the buffer
size.
	That's why I would prefer a separate patch about those issues
that give the opportunity for the stakeholder to really talk about
this, rather than slipping it under the carpet.
	In the worse case, this is not a bug, this just means that we
may not use the last char of the buffer.

> > > 2. shouldn't there be (here and above):
> > >  
> > > 		envp[--i] = NULL;
> > > 
> > 
> > 	No, envp is local, so who cares.
> 
> But envp[i] isn't (at least here). So, I guess, a caller
> of this function could care.

	Check the full source code of the caller, and you will see
that the caller does not care (and it's local to the caller).

> > > > + 	if ((size <= 0) || (i >= num_envp))
> > > > + 		return -ENOMEM;
> 
> And one more thing (not necessarily for you):
> ENOBUFS is probably more adequate here.

	This error should never happen. If it happens, the caller need
to be fixed.

> Cheers,
> Jarek P.

	Note that there are various other things that are puzzling in
this function. The internal object name and the symlinks are changed
even if the kcore rename returns an error. That does not seem right.
	But, this is separate from this patch...

	Have fun...

	Jean
