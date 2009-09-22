From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: fanotify as syscalls
Date: Tue, 22 Sep 2009 23:38:32 +0200
Message-ID: <200909222338.32646.agruen@suse.de>
References: <20090912094110.GB24709@ioremap.net> <200909212204.51077.agruen@suse.de> <1253653576.2747.27.camel@dhcp231-106.rdu.redhat.com>
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1253653576.2747.27.camel@dhcp231-106.rdu.redhat.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 22 September 2009 23:06:16 Eric Paris wrote:
> this is true, if there is only one namespace subtree notification works
> the same as global notification.
>
> [...]
>
> I don't see how subtree notification can possibly solve the global
> notification problem.

I'm thinking of is something like this: A listener registers interest in "/", 
recursively. The kernel sets a FSNOTIFY_WATCH_RECURSIVE flag on "/" and each 
mount point below. Afterwards when something is mounted anywhere, same 
namespace or not, the kernel sets the new mount's FSNOTIFY_WATCH_RECURSIVE 
flag if the parent mount has this flag set.

(Of course we need per fsnotify_group flags and not global ones, but this 
doesn't change the principle.)

Andreas
