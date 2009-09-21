From: Jamie Lokier <jamie@shareable.org>
Subject: Re: fanotify as syscalls
Date: Mon, 21 Sep 2009 23:00:02 +0100
Message-ID: <20090921220002.GE14700@shareable.org>
References: <20090912094110.GB24709@ioremap.net> <200909212204.51077.agruen@suse.de> <20090921202823.GB14700@shareable.org> <200909212327.20978.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Andreas Gruenbacher <agruen@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200909212327.20978.agruen@suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Gruenbacher wrote:
> On Monday, 21 September 2009 22:28:23 Jamie Lokier wrote:
> > It would be logical if fanotify could block and ack those [mount & umount
> > events] in the same way as it can block and ack other accesses (with the
> > usual filtering rules on which inodes trigger events, and which don't or are
> > cached).
> 
> Hmm. To me, fanotify is about file contents first of all: this is what 
> fanotify wants to be able to veto.

Surely you don't assume that what constitutes malicious content is
independent of it's location and/or name?

(See also "echo 'run_virus&' >>.bash_login).

Wait a minute.  You don't assume that, otherwise why the interest in
subtrees? :-)

> Directory events seem reasonable to add for inotify compatibility,

Did you see may point about userspace caches and how directory events
are fundamental to that - there's no way to build a cache without them?

> but I see no need for access decisions on them. 

Please excuse me; I'm a bit confused.  Is fanotify intended just for
use by access decision programs, or is the plan now for it to also be
a replacement for inotify?  I'm getting conflicting signals about
that.

If it's just for access decision programs, and if those aren't going
to care about location, then there's no need to add directory events
to fanotify at all.  But then I'll be demanding subtree support in
inotify, please :-)

> Even less so for mounts and unmounts.

   (as root) mkdir foo; mount dodgy foo -oloop; mount --bind foo/cat /bin/cat

If fanotify doesn't react to that, which is just a fancy way of saying
"zcat virus.gz >/bin/cat" in a way which doesn't cause any writes or
opens, what's the point in it?  Is fanotify only for checking files
written by non-root users?

> (Besides, we can't hold any vfs locks 
> while asking fanotify so those operations wouldn't be atomic, anyway.)

Indeed, good point.

-- Jamie
