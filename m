From: Andi Kleen <ak@suse.de>
Subject: Re: Zero copy transmit
Date: Tue, 29 Apr 2003 21:41:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429194131.GA349@Wotan.suse.de>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de> <20030429193336.GA32270@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Steve Modica <modica@sgi.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robin Holt <holt@sgi.com>
Content-Disposition: inline
In-Reply-To: <20030429193336.GA32270@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2003 at 02:33:36PM -0500, Robin Holt wrote:
> On Tue, Apr 29, 2003 at 09:20:41PM +0200, Andi Kleen wrote:
> > A much better way would be to use the POSIX aio interfaces. They support
> > zero copy transmit, but don't require COW. Instead they just tell
> > the user process when it is safe to touch the buffer again.
> > 
> > There was already some code to do aio TCP sending, but it didn't
> > do zero copy and was not merged for some reason.
> > 
> > Also you can already do zero copy transmit using sendfile() 
> 
> Users would need to rewrite all their apps to use either the async or
> sendfile method.  That assumption seems a little broad.

In my experience only a few programs are performance critical in this 
way; and their developers/users usually do not mind changing their programs 
a bit to get the best performance. In fact they are always happy when
they get such knobs from you ;)

>      
> I don't disagree that implementing the remainder of the AIO system
> calls would also be good, but is there something wrong with getting
> write et. al. to work with zero copy?

You have to ask DaveM/Alexey - they had it, but rejected it, apparently
also based on some bad experiences on other operating systems.

I can see their point - e.g. in the worst case each write could
trigger two TLB flush IPIs to all CPUs in the system (one to COW it 
and another to un COW it). You can copy a lot of data in the time
it takes to process all of them, especially on a big machine.

-Andi
