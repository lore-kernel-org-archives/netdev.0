From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 05:44:58 +0100
Message-ID: <20151022044458.GP22011@ZenIV.linux.org.uk>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <20151021.182955.1434243485706993231.davem@davemloft.net>
 <5628636E.1020107@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org, casper.dik@oracle.com
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59832 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbJVEpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 00:45:04 -0400
Content-Disposition: inline
In-Reply-To: <5628636E.1020107@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 05:17:50AM +0100, Alan Burlison wrote:

> It's been said that the current mechanisms in Linux & some BSD
> variants can be subject to races

You do realize that it goes for the entire area?  And the races found
in this thread are in the BSD variant that tries to do something similar
to what you guys say Solaris is doing, so I'm not sure which way does
that argument go.  A high-level description with the same level of details
will be race-free in _all_ of them.  The devil is in the details, of course,
and historically they had been very easy to get wrong.  And extra complexity
in that area doesn't make things better.

>, and the behaviour exhibited
> doesn't conform to POSIX, for example requiring the use of
> shutdown() on unconnected sockets because close() doesn't kick off
> other threads accept()ing on the same fd.

Umm...  The old kernels (and even more - old userland) are not going to
disappear, so we are stuck with such uses of shutdown(2) anyway, POSIX or
no POSIX.

> I'd be interested to hear
> if there's a better and more performant way of handling the
> situation that doesn't involve doing the sort of bookkeeping Casper
> described,.

So would a lot of other people.

> To quote one of my colleague's favourite sayings: Performance is a
> goal, correctness is a constraint.

Except that in this case "correctness" is the matter of rather obscure and
ill-documented areas in POSIX.  Don't get me wrong - this semantics isn't
inherently bad, but it's nowhere near being an absolute requirement.
