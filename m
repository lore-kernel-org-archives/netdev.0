From: Glenn Fowler <gsf@research.att.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 14:14:57 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307231814.OAA74344@raptor.research.att.com>
References: <200307231428.KAA15254@raptor.research.att.com>  <20030723074615.25eea776.davem@redhat.com>  <200307231656.MAA69129@raptor.research.att.com>  <20030723100043.18d5b025.davem@redhat.com>  <200307231724.NAA90957@raptor.research.att.com> <20030723103135.3eac4cd2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dgk@research.att.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, gsf@research.att.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 23 Jul 2003 10:31:35 -0700 David S. Miller wrote:
> Interesting.

> I looked at the bash code, and it uses pipes with /dev/fd/N, and for
> /dev/fd/N which are pipes the open should work under Linux.

> This is what David Korn said in his original report.

> I guess the part that is left is the fchmod() issue which exists
> because one inode is used to implement both sides of the pipe under
> Linux.

> Was the idea to, since fchmod() on pipes modified both sides,
> to use UNIX domain sockets to implement this?  And that's how
> you discovered the /dev/fd/N failure for sockets?

fchmod() came into play with socketpair() to get the fd modes to match
pipe(); its not needed with pipe()

we use socketpair() to allow efficient peeking on pipe input (via recv()),
where peek means "read some data but don't advance the read/seek offset"
btw, this is on systems that don't allow ioctl(I_PEEK) on pipe() fds;
if there is a way to peek pipe() data on linux then we can switch back
to pipe() and be on our way

> Another idea is to use named unix sockets.  Can that be
> sufficient to solve your dilemma?

named sockets seem a little heavyweight for this application
