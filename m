From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 00:16:20 +0400
Message-ID: <20090915201620.GB32192@ioremap.net>
References: <20090911.114620.260824240.davem@davemloft.net> <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com> <20090911204602.GA19371@shareable.org> <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com> <20090911212731.GA19901@shareable.org> <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com> <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org> <20090914140720.GA8564@ioremap.net> <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org,
	torvalds@linux-foundation.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 14, 2009 at 03:08:15PM -0400, Eric Paris (eparis@redhat.com) wrote:
> Just this week I got another request to look at syscalls.  So I did, I
> haven't prototyped it, but I can do it with syscalls, they would look
> like this:
> 
> int fanotify_init(int flags, int f_flags, __u64 mask, unsigned int priority);

...

> Are there demands that I convert to syscalls?  Do I really gain anything
> using 9 new inextensible syscalls over socket(), bind(), and 8
> setsockopt() calls?

In my personal opinion sockets are way much simpler and obvious than
syscalls. Also one should not edit hundred of arch-dependant headers
conflicting with other pity syscallers.

But implementing af_fanotify opens a door for zillions of other
af_something which can be implemented using existing infrastructure
namely netlink will solve likely 99% of potential usage cases.

And frankly I did not find it way too convincing that using netlink is
impossible in your scenario if some things will be simplified, namely
event merging. Moreover you can implement a pool of working threads and
postpone all the work to them and appropriate event queues, which will
allow to use rlimits for the listeners and open files 'kind of' on
behalf of those processes.

But it is quite diferent from the approach you selected and which is
more obvious indeed. So if you ask a question whether fanotify should
use sockets or syscalls, I would prefer sockets, but I still recommend
to rethink your decision to move away from netlink to be 100% sure that
it will not solve your needs.

-- 
	Evgeniy Polyakov
