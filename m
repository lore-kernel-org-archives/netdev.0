From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] isdnloop: NUL-terminate strings from userspace
Date: Tue, 1 Apr 2014 15:35:34 +0300
Message-ID: <20140401123534.GE18506@mwanda>
References: <1396346898-8950-1-git-send-email-vegard.nossum@oracle.com>
 <20140401103020.GG24150@order.stressinduktion.org>
 <533A990D.2040609@oracle.com>
 <20140401110255.GH24150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Vegard Nossum <vegard.nossum@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140401110255.GH24150@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 01, 2014 at 01:02:55PM +0200, Hannes Frederic Sowa wrote:
> On Tue, Apr 01, 2014 at 12:46:37PM +0200, Vegard Nossum wrote:
> > On 04/01/2014 12:30 PM, Hannes Frederic Sowa wrote:
> > >Looking down the problem, it seems the problem is that the strlen in 
> > >strlcpy
> > >could read beyond the input buffer?
> > >
> > >To prevent this problem in other parts of the kernel wouldn't it be better 
> > >to
> > >replace the strlen with strnlen in strlcpy?
> > 
> > Sorry, I should have included the link to the previous thread: 
> > https://lkml.org/lkml/2014/3/7/712
> > 
> > I only resent (adding netdev to Cc) to get this into David Miller's 
> > patch queue.
> 
> Ah ok, sorry I don't follow lkml as closely as netdev@.
> 
> > As you can see from the previous discussion, we _could_ change the Linux 
> > kernel's definition of strlcpy(), but I wouldn't recommend it for the 
> > following reasons:
> > 
> > 1. Both BSD man page and BSD implementation _require_ the source string 
> > to be 0-terminated. Changing the semantics of strlcpy() in the Linux 
> > kernel would probably be a bad idea and cause even more confusion that 
> > what we already have.
> 
> Sure, we shouldn't change the documented semantics. If at all it would
> be an additional safety net. Your patch would still be needed.
> 

Guys, really?  How would the patch "still be needed"?  I feel like if
someone said we had to rub a chicken head on this code we do it in the
name of security...

I don't understand what you think the point of strlcpy() is, if it's not
to deal with source strings which aren't NUL terminated.

I still maintain that the since the stack is full of NUL characters the
current implimentation of strlcpy() is ok for this isdn_loop function
and the patch is not needed at all without the strnlen() change.

However for other heap allocated variables then I could imagine that
the strlen() might be a problem.  I have two theories why we have never
seen problems with this in running code. 1) The string would have to be
at the end of a struct allocated at the end of a page.  You have to be
very unlucky to hit this requirement.  2) Most people pass valid data.

regards,
dan carpenter
