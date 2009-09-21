From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: fanotify as syscalls
Date: Mon, 21 Sep 2009 23:27:20 +0200
Message-ID: <200909212327.20978.agruen@suse.de>
References: <20090912094110.GB24709@ioremap.net> <200909212204.51077.agruen@suse.de> <20090921202823.GB14700@shareable.org>
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090921202823.GB14700@shareable.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 21 September 2009 22:28:23 Jamie Lokier wrote:
> It would be logical if fanotify could block and ack those [mount & umount
> events] in the same way as it can block and ack other accesses (with the
> usual filtering rules on which inodes trigger events, and which don't or are
> cached).

Hmm. To me, fanotify is about file contents first of all: this is what 
fanotify wants to be able to veto. Directory events seem reasonable to add 
for inotify compatibility, but I see no need for access decisions on them. 
Even less so for mounts and unmounts. (Besides, we can't hold any vfs locks 
while asking fanotify so those operations wouldn't be atomic, anyway.)

Thanks,
Andreas
