From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 07:46:15 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030723074615.25eea776.davem@redhat.com>
References: <200307231428.KAA15254@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gsf@research.att.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: David Korn <dgk@research.att.com>
In-Reply-To: <200307231428.KAA15254@raptor.research.att.com>
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 10:28:22 -0400 (EDT)
David Korn <dgk@research.att.com> wrote:

> This make sense for INET sockets, but I don't understand the security
> considerations for UNIX domain sockets.  Could you please elaborate?
> Moreover, /dev/fd/n, (as opposed to /proc/$$/n) is restricted to
> the current process and its decendents if close-on-exec is not specified.
> Again, I don't understand why this would create a security problem
> either since the socket is already accesible via the original
> descriptor.

Someone else would have to comment, but I do know we've had
this behavior since day one.

And therefore I wouldn't be doing many people much of a favor
by changing the behavior today, what will people do who need
their things to work on the bazillion existing linux kernels
running out there? :-)

Also, see below for another reason why this behavior is unlikely
to change.

> Finally if this is a security problem, why is the errno is set to ENXIO 
> rather than EACCESS?

Look at the /proc file we put there for socket FD's.  It's a symbolic
link with a readable string of the form ("socket:[%d]", inode_nr)

So your program ends up doing a follow of a symbolic link with that
string name, which does not exist.

Thinking more about this, changing this behavior would probably break
more programs than it would help begin to function, so this is unlikely
to ever change.
