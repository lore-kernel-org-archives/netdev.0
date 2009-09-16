From: Eric Paris <eparis@redhat.com>
Subject: Re: fanotify as syscalls
Date: Tue, 15 Sep 2009 21:26:31 -0400
Message-ID: <1253064391.5213.37.camel@dhcp231-106.rdu.redhat.com>
References: <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
	 <20090911204602.GA19371@shareable.org>
	 <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
	 <20090911212731.GA19901@shareable.org>
	 <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
	 <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org>
	  <20090914140720.GA8564@ioremap.net>
	 <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
	 <20090915201620.GB32192@ioremap.net>
	 <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
	 <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.01.0909151643540.4950@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-09-15 at 16:49 -0700, Linus Torvalds wrote:

> And btw, I still want to know what's so wonderful about fanotify that we 
> would actually want yet-another-filesystem-notification-interface. So I'm 
> not sayying that I'll take a system call interface.

The real thing that fanotify provides is an open fd with the event
rather than some arbitrary 'watch descriptor' that userspace must
somehow magically map back to data on disk.  This means that it could be
used to provide subtree notification, which inotify is completely
incapable of doing.  And it can be used to provide system wide
notification.  We all know who wants that.

It provides an extensible data format which allows growth impossible in
inotify.  I don't know if anyone remember the inotify patches which
wanted to overload the inotify cookie field for some other information,
but inotify information extension is not reasonable or backwards
compatible.

fanotify also allows userspace to make access decisions and cache those
in the kernel.  Useful for integrity checkers (anti-malware people) and
for hierarchical storage management people.

I've got private commitments for two very large anti malware companies,
both of which unprotect and hack syscall tables in their customer's
kernels, that they would like to move to an fanotify interface.  Both
Red Hat and Suse have expressed interest in these patches and have
contributed to the patch set.

The patch set is actually rather small (entire set of about 20 patches
is 1800 lines) as it builds on the fsnotify work already in 2.6.31 to
reuse code from inotify rather than reimplement the same things over and
over (like we previously had with inotify and dnotify)

Don't know what else to say.....

-Eric

