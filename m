From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: fanotify as syscalls
Date: Thu, 17 Sep 2009 09:40:16 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0909170934450.4950@localhost.localdomain>
References: <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com> <20090911212731.GA19901@shareable.org> <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com> <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org> <20090914140720.GA8564@ioremap.net>
 <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com> <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com> <20090916120523.GA12830@ioremap.net> <20090916122723.GE29359@shareable.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Eric Paris <eparis@redhat.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37225 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751718AbZIQQkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 12:40:49 -0400
In-Reply-To: <20090916122723.GE29359@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 16 Sep 2009, Jamie Lokier wrote:
> 
> I'd forgotten about Linus' strace argument.  That's a good one.
> 
> Of course everything should be a syscall by that argument :-)

Oh yes, everything _should_ be a syscall.

The problem is that many things are too "amorphous" to be system calls, 
and don't have any sane generic semantics (ie they only act on a specific 
device node). So we have ioctl's etc for those things.

And then we have page faults. I've long wished that from a system call 
tracing standpoint we could show page faults as pseudo-system-calls (at 
least as long as they happen from user space - trying to handle nesting is 
not worth it). It would make it _so_ much more obvious what the 
performance patterns are if you could just do

	strace -ttT firefox

for the cold-cache case and you'd see where the time is really spent.

(yeah, yeah, you can get that kind of information other ways, but it's a 
hell of a lot less convenient than just getting a nice trace with 
timestamps).

> And strace can trace some ioctls and setsockopts.  (But it's never
> pretty to see isatty() showing in strace as SNDCTL_TMR_TIMEBASE :-)

Yes, strace can fix things up, and show "send a packet" as "fanotify". But 
it's nasty and hard. 

Quite frankly, I have _never_ever_ seen a good reason for talking to the 
kernel with some idiotic packet interface. It's just a fancy way to do 
ioctl's, and everybody knows that ioctl's are bad and evil. Why are fancy 
packet interfaces suddenly much better?

			Linus
