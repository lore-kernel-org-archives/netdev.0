From: David Korn <dgk@research.att.com>
Subject: Re: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 10:28:22 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200307231428.KAA15254@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gsf@research.att.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: davem@redhat.com
List-Id: netdev.vger.kernel.org


> On Wed, 23 Jul 2003 09:32:09 -0400 (EDT)
> David Korn <dgk@research.att.com> wrote:
> 
> [ Added netdev@oss.sgi.com, the proper place to discuss networking kernel issues
> . ]
> 
> > The first problem is that files created with socketpair() are not accessible
> > via /dev/fd/n or /proc/$$/fd/n where n is the file descriptor returned
> > by socketpair().  Note that this is not a problem with pipe().
> 
> Not a bug.
> 
> Sockets are not openable via /proc files under any circumstances,
> not just the circumstances you describe.  This is a policy decision and
> prevents a whole slew of potential security holes.
> 
> 

Thanks for you quick response.

This make sense for INET sockets, but I don't understand the security
considerations for UNIX domain sockets.  Could you please elaborate?
Moreover, /dev/fd/n, (as opposed to /proc/$$/n) is restricted to
the current process and its decendents if close-on-exec is not specified.
Again, I don't understand why this would create a security problem
either since the socket is already accesible via the original
descriptor.

Finally if this is a security problem, why is the errno is set to ENXIO 
rather than EACCESS?

David Korn
dgk@research.att.com
