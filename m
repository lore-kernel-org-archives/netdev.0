From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH 1/5] tun check error on memcpy_fromiovec
Date: Thu, 22 Jan 2004 18:13:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122181353.J2962@osdlab.pdx.osdl.net>
References: <20031208202302.C30587@build.pdx.osdl.net> <20031219103457.GD1213@mail.sternwelten.at> <20040116164512.C19034@osdlab.pdx.osdl.net> <1074718162.1707.194.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, maximilian attems <janitor@sternwelten.at>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Max Krasnyansky <maxk@qualcomm.com>
Content-Disposition: inline
In-Reply-To: <1074718162.1707.194.camel@localhost>; from maxk@qualcomm.com on Wed, Jan 21, 2004 at 12:49:23PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Max Krasnyansky (maxk@qualcomm.com) wrote:
> On Fri, 2004-01-16 at 16:45, Chris Wright wrote:
> > I specifically left those alone.  They have a semi-bogus verify_area()
> > call that is trying to insure the memcpy_fromiovec won't EFAULT.  I'd
> > prefer to remove them and simply do memcpy checking.
> 
> Please don't add extra unneeded checks or fix stuff that does not need
> to be fixed. Verify area is not bogus. We need to know total length of
> the iovec so we might as well check it in the same loop and not bother
> with checking later. 

Yes, I realize it's used to collect total length.  But it does not protect
from userspace controlled buffer whose contents can change.  Continuing
when a fault is possible means the skb->data could be zero'd.  However,
since this is intended to be 0700 root owned device, and the user could
supply same such data directly, it's of fairly low priority to patch.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
