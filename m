From: Andi Kleen <ak@suse.de>
Subject: Re: Zero copy transmit
Date: Tue, 29 Apr 2003 21:20:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429192041.GC17413@Wotan.suse.de>
References: <3EAEC7FF.4040504@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
Content-Disposition: inline
In-Reply-To: <3EAEC7FF.4040504@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2003 at 01:44:15PM -0500, Steve Modica wrote:
> We are doing some experiementing with Altix systems (Itanium II with
> NUMA) and we're taking a big hit from __copy_user traffic.  We would
> like to modify the write, writev, send and sendto interfaces such that
> we can avoid the __copy_user call by marking pages copy-on-write (COW)
> and handing them off to be transmitted.  Since this requires TLB 
> updates, we would only implement this code on platforms that defined 
> themselves as capable of fast TLB updates.

A much better way would be to use the POSIX aio interfaces. They support
zero copy transmit, but don't require COW. Instead they just tell
the user process when it is safe to touch the buffer again.

There was already some code to do aio TCP sending, but it didn't
do zero copy and was not merged for some reason.

Also you can already do zero copy transmit using sendfile() 

Linux basically has all the infrastructure you need for this already;
just the high level interface to the AIO system calls is still missing.

-Andi
