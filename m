From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Thu, 24 Jun 2010 21:42:04 -0700
Message-ID: <20100624214204.a85c8ba2.akpm@linux-foundation.org>
References: <20100624182123.45264dfe.akpm@linux-foundation.org>
	<20100624.203006.35035648.davem@davemloft.net>
	<20100624205059.a28756b0.akpm@linux-foundation.org>
	<20100624.212713.242141362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, shemminger@vyatta.com,
	mpm@selenic.com, paulmck@linux.vnet.ibm.com,
	a.p.zijlstra@chello.nl, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33869 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750949Ab0FYEmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 00:42:38 -0400
In-Reply-To: <20100624.212713.242141362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jun 2010 21:27:13 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 24 Jun 2010 20:50:59 -0700
> 
> > What happens if you want to actually *drop* a patch from net-next? 
> > Surely that happens?
> 
> I've only respun the tree on two or three occasions and that was
> because I made some significant error myself and screwed up the
> GIT tree somehow.
> 
> We've fixed much worse bugs than this one weeks after the changes
> causing them went in, life goes on.

Still sucks - this is a quite ugly drawback to how we're using git. 
I've hit bisection holes several times which held up the show. 
Sometimes you can make them go away by fiddling the .config, other
times I've hunted down the fix and manually applied it for each
iteration.  It makes me feel all guilty each time I ask some poor sap
to bisect a bug for us.

> And the fact that it took two weeks of it being in -next before
> anyone even reported it says how wide a net this particular bug
> covers :-)  (hint: personally I've still never used netconsole
> even one single time, and it's been around for what, something
> like 6 years?)

I'd imagine that netconsole would get in the way rather a lot for net
developers, but it's really useful!


That being said, I wonder why Herbert didn't hit this in his testing. 
I suspect that he'd enabled lockdep, which hid the bug.  I haven't
worked out _why_ lockdep hides the double-mutex_unlock bug, but it's a
pretty bad thing to do.

Presumably mutex debugging _would_ have found it, but because the bug
was in netconsole code, the mutex-debugging blurt of course didn't come
out.  We don't replay the log buffer when netconsole is brought up -
perhaps we should.

And that machine has a screwy USB keyboard on which I've never managed
to invoke the vt-srcoll-backwards thing, so it would have been darned
hard for me to see and mutex-debugging warnings anyway.
