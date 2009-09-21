From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: fanotify as syscalls
Date: Tue, 22 Sep 2009 01:09:05 +0200
Message-ID: <200909220109.05995.agruen@suse.de>
References: <20090912094110.GB24709@ioremap.net> <200909212327.20978.agruen@suse.de> <20090921220002.GE14700@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754374AbZIUXJn@vger.kernel.org>
In-Reply-To: <20090921220002.GE14700@shareable.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 22 September 2009 0:00:02 Jamie Lokier wrote:
> Andreas Gruenbacher wrote:
> > On Monday, 21 September 2009 22:28:23 Jamie Lokier wrote:
> > > It would be logical if fanotify could block and ack those [mount &
> > > umount events] in the same way as it can block and ack other accesses
> > > (with the usual filtering rules on which inodes trigger events, and
> > > which don't or are cached).
> >
> > Hmm. To me, fanotify is about file contents first of all: this is what
> > fanotify wants to be able to veto.
>
> Surely you don't assume that what constitutes malicious content is
> independent of it's location and/or name?

If the antimalware vendors want to base their decisions on pathnames then 
that's their decision, and they can check /proc/self/fd/N. We should be able 
to treat directory events the same.

> (See also "echo 'run_virus&' >>.bash_login).
>
> Wait a minute.  You don't assume that, otherwise why the interest in
> subtrees? :-)
>
> > Directory events seem reasonable to add for inotify compatibility,
>
> Did you see may point about userspace caches and how directory events
> are fundamental to that - there's no way to build a cache without them?

Yes, there were some doubts about this appoach. Waiting for your code to 
demonstrate; an object based cache (e.g., st_dev + st_ino) rather than a 
pathname based cache would seem more reasonable.

> > but I see no need for access decisions on them.
>
> Please excuse me; I'm a bit confused.  Is fanotify intended just for
> use by access decision programs, or is the plan now for it to also be
> a replacement for inotify?  I'm getting conflicting signals about
> that.

Inotify doesn't support access decisions. So where's the problem with 
having "notify only" events for directory / mount / unmount events?

> If it's just for access decision programs, and if those aren't going
> to care about location, then there's no need to add directory events
> to fanotify at all.  But then I'll be demanding subtree support in
> inotify, please :-)
>
> > Even less so for mounts and unmounts.
>
>    (as root) mkdir foo; mount dodgy foo -oloop; mount --bind foo/cat
> /bin/cat

... and then someone accesses /bin/cat, which triggers a fanotify access 
decision.

Thanks,
Andreas
