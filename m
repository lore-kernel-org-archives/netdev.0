From: Eric Paris <eparis@redhat.com>
Subject: Re: fanotify as syscalls
Date: Fri, 18 Sep 2009 16:52:08 -0400
Message-ID: <1253307128.2552.21.camel@dhcp231-106.rdu.redhat.com>
References: <20090912094110.GB24709@ioremap.net>
	 <1253094537.5213.89.camel@dhcp231-106.rdu.redhat.com>
	 <20090916121708.GD29359@shareable.org>  <200909172207.01764.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Andreas Gruenbacher <agruen@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <200909172207.01764.agruen@suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-09-17 at 22:07 +0200, Andreas Gruenbacher wrote:

> From my point of view, "global" events make no sense, and fanotify listeners 
> should register which directories they are interested in (e.g., include "/", 
> exclude "/proc"). This takes care of chroots and namespaces as well.

While I completely agree that most users don't want global events, the
antimalware vendors who today, unprotect and hack the syscall table on
their unsuspecting customer's machines to intercept every read, write,
open, close, mmap, etc syscall want EXACTLY that.  They'd been asking
for a way to get this information for quite some time now.  The largest
vendors in this market have agreed the interface (well, when it was a
socket interface that I talked about for so long) should meet their
needs.

Subtree watching / isn't any different or better, just harder and more
complex to implement.  You still have to exclude /proc and /sys and
everything else.  Just like one must with a global listener.  Still
though, this sounds like an issue for the f_type and f_fsid exclusion
syscall I say I'm still not settled on.  Not and issue with the basis of
fanotify or with the 3 proposed syscalls.

Jamie, do you see a problem with what I have been asking for review on
or see a problem with extending it moving forward?

Linus, do you see the value of 'yet another notification scheme' ?

-Eric

