From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 10:31:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723103135.3eac4cd2.davem@redhat.com>
References: <200307231428.KAA15254@raptor.research.att.com>
	<20030723074615.25eea776.davem@redhat.com>
	<200307231656.MAA69129@raptor.research.att.com>
	<20030723100043.18d5b025.davem@redhat.com>
	<200307231724.NAA90957@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gsf@research.att.com, dgk@research.att.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Glenn Fowler <gsf@research.att.com>
In-Reply-To: <200307231724.NAA90957@raptor.research.att.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 13:24:36 -0400 (EDT)
Glenn Fowler <gsf@research.att.com> wrote:

> /dev/fd/N is the underlying mechanism for implementing the bash and ksh
> 
> 	cmd-1 <(cmd-2 ...) ... <(cmd-n ...)
> 

Interesting.

I looked at the bash code, and it uses pipes with /dev/fd/N, and for
/dev/fd/N which are pipes the open should work under Linux.

This is what David Korn said in his original report.

I guess the part that is left is the fchmod() issue which exists
because one inode is used to implement both sides of the pipe under
Linux.

Was the idea to, since fchmod() on pipes modified both sides,
to use UNIX domain sockets to implement this?  And that's how
you discovered the /dev/fd/N failure for sockets?

Another idea is to use named unix sockets.  Can that be
sufficient to solve your dilemma?
