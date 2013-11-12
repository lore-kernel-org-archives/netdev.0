From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH net-next 3/6] random32: add prandom_reseed_late() and
 call when nonblocking pool becomes initialized
Date: Tue, 12 Nov 2013 06:53:50 -0500
Message-ID: <20131112115350.GA14077@thunk.org>
References: <cover.1384160397.git.dborkman@redhat.com>
 <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
 <20131111134357.GC10104@thunk.org>
 <20131112000307.GB14929@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:56994 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709Ab3KLLyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 06:54:02 -0500
Content-Disposition: inline
In-Reply-To: <20131112000307.GB14929@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 12, 2013 at 01:03:07AM +0100, Hannes Frederic Sowa wrote:
>
> We are much too early to enumerate hardware, so it would be hard to
> integrate something like mac addresses etc.

Stupid question --- is there a reason why the minstrel code is
initialized so early when it is compiled into the kernel?  Can we
change it so it gets initialized later, after the devices are
initialized and we get the mac addresses?  

> Btw. do you see problems regarding get_random_int on architectures without
> hardware offloading?
> 
> We are initializing random_int_secret really late (after all the init
> calls) and I wonder if we should also use a two stage initialization
> there, so we have a more unpredictable MD5 hash at early boot.

Most of the users of get_random_int(), at least to date, have been for
things like ASLR.  A quick audit shows only one device driver user
that might be impacted: drivers/net/wireless/cw1200/wsm.c.

It's not a bad idea to do a two stage init just in case
get_random_int() gets used by other code --- although that brings up
something that I know is really needed, but which I haven't had time
to try to address yet: we really need to document all of the various
interfaces that various kernel routines can use to get random numbers,
and document what their performance and security characteristics are.
We have probably have a lot of code where the authors didn't realize
that some other interface would be a better match for their needs, or
the code is old enough that predates some of the newer interfaces.

    	    	       	    	     - Ted
