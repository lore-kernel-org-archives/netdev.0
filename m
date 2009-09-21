From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: fanotify as syscalls
Date: Mon, 21 Sep 2009 22:04:50 +0200
Message-ID: <200909212204.51077.agruen@suse.de>
References: <20090912094110.GB24709@ioremap.net> <200909190000.43556.agruen@suse.de> <1253329471.2630.30.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:51164 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574AbZIUUFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 16:05:23 -0400
In-Reply-To: <1253329471.2630.30.camel@dhcp231-106.rdu.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, 19 September 2009 5:04:31 Eric Paris wrote:
> Let me start by saying I am agreeing I should pursue subtree
> notification.  It's what I think everyone really wants.  It's a great
> idea, and I think you might have a simple way to get close.  Clearly
> these are avenues I'm willing and hoping to pursue.  Also I say it
> again, I believe the interface as proposed (except maybe some of my
> exclusion stuff) is flexible enough to implement any of these ideas.
> Does anyone disagree?

It does seem flexible enough. However, the current interface assumes "global" 
listeners (the mask argument of fanotify_init):

  int fanotify_init(int flags, int f_flags, __u64 mask,
		    unsigned int priority);

Once subtree support is added, this parameter becomes obsolete. That's pretty 
broken for a syscall yet to be introduced.

> BUT to solve one of the main problems fanotify is intending to solve it
> needs a way to be the 'fscking all notifier.'  It needs to be the whole
> damn system.

Think of a system after boot, with a single global namespace. Whatever you 
access by filename is reachable from the namespace root. At this point, 
nothing more global exists. A listener can watch the mount points of 
interest, and everything's fine.

What's a bit more tricky is to ensure that this listener will continue to 
receive all events from whatever else is mounted anywhere, irrespective of 
namespaces. I think we can get there.

By the way, Documentation/filesystems/sharedsubtree.txt describes how 
filesystem namespaces work.

Thanks,
Andreas
