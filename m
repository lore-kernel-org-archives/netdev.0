From: David Korn <dgk@research.att.com>
Subject: Re: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 15:28:52 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307231928.PAA75996@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, dgk@research.att.com, gsf@research.att.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

cc:  gsf@research.att.com  dgk@research.att.com  linux-kernel@vger.kernel.org     netdev@oss.sgi.com
Subject: Re: Re: kernel bug in socketpair()
--------

> I missed the reason why you can't use pipes and bash
> is able to, what is it?
> 
> If it's the fchown() thing, why doesn't bash have this issue?
> 
> 

The reason is that we want to be able to peek ahead at data in
the pipe before advancing.  You can do this with recv() but
this doesn't work wtih pipes.   On some systems you can use
an ioctl() for this with pipes by Linux doesn't support this
so ksh configures to use socketpair() instead of pipe()
on Linux.  Without the ability to peek ahead on pipes, a command
like
	cat file | { head -6 > /dev/null; cat ;}
to remove the first 6 lines of a file would be hard to implement
unless head reads one byte at a time from the pipe.
(OK, you could read 6 bytes at first if you want to optimize head.)

David Korn
dgk@research.att.com
