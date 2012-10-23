From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/2] packet: clean up error variable assignments
Date: Wed, 24 Oct 2012 00:10:24 +0100
Message-ID: <1351033824.5283.80.camel@deadeye.wl.decadent.org.uk>
References: <20121023115629.GA8664@thinkbox>
	 <1351011952.8609.2334.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dxchgb@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60821 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933464Ab2JWXK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 19:10:28 -0400
In-Reply-To: <1351011952.8609.2334.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-23 at 19:05 +0200, Eric Dumazet wrote:
> On Tue, 2012-10-23 at 13:56 +0200, Daniel Borkmann wrote:
> > This patch performs clean-ups of packet's err variables where appropriate.
> > In particular, errnos are *only* assigned in error cases, which saves
> > useless instructions in non-error cases and makes the code more readable
> > in terms of which error type belongs to which evaluated error condition.
> > Also, in some cases an errno was set, but not used until the next assignment.
> 
> I see no value in this patch.
> 
> Setting err before a test is a common way to handle error cases and
> generates smaller code in linux kernel.
>
> Better live with it than trying to change it ?
> 
> err = -ENOMEM;
> match = kzalloc(xxxx);
> if (!match)
> 	goto error;
> 
> 
> is smaller (source code & generated code) than :
> 
> match = kzalloc(xxxx);
> if (!match) {
> 	err = -ENOMEM;
> 	goto error;
> }
>
> An immediate load is basically free, but code size matters.

In my experience gcc is generally able to perform this optimisation
itself, at least for x86.  Setting 'err' only after checking for failure
seems clearer, but I think this is really a matter of taste.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
