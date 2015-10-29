From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 00:15:32 +0000
Message-ID: <20151029001532.GE22011@ZenIV.linux.org.uk>
References: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151028123543.GB22011@ZenIV.linux.org.uk>
 <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
 <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151028211347.GC22011@ZenIV.linux.org.uk>
 <1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151028223330.GD22011@ZenIV.linux.org.uk>
 <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59900 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbbJ2APg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 20:15:36 -0400
Content-Disposition: inline
In-Reply-To: <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 04:08:29PM -0700, Eric Dumazet wrote:
> > > Except for legacy stuff and stdin/stdout/stderr games, I really doubt
> > > lot of applications absolutely rely on the POSIX thing...
> > 
> > We obviously can't turn that into default behaviour, though.  BTW, what
> > distribution do you have in mind for those random descriptors?  Uniform
> > on [0,INT_MAX] is a bad idea for obvious reasons - you'll blow the
> > memory footprint pretty soon...
> 
> Simply [0 , fdt->max_fds] is working well in most cases.

Umm...  So first you dup2() to establish the ->max_fds you want, then
do such opens?  What used/unused ratio do you expect to deal with?
And what kind of locking are you going to use?  Keep in mind that
e.g. dup2() is dependent on the lack of allocations while it's working,
so it's not as simple as "we don't need no stinkin' ->files_lock"...
