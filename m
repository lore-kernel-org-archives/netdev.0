From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH 1/5] tun check error on memcpy_fromiovec
Date: Wed, 21 Jan 2004 12:49:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1074718162.1707.194.camel@localhost>
References: <20031208202302.C30587@build.pdx.osdl.net>
	 <20031219103457.GD1213@mail.sternwelten.at>
	 <20040116164512.C19034@osdlab.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: maximilian attems <janitor@sternwelten.at>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20040116164512.C19034@osdlab.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-01-16 at 16:45, Chris Wright wrote:
> * maximilian attems (janitor@sternwelten.at) wrote:
> > hey chris,
> > 
> > after applying your 4 patches on top of linux-2.6.0 
> > + experimental net, 
> > found 2 last unchecked memcpy_fromiovec in tun.c
> > patch bellow fixes the second call, 
> > the first is beyond me, please complete this patch :)
> > compile tested
> 
> I specifically left those alone.  They have a semi-bogus verify_area()
> call that is trying to insure the memcpy_fromiovec won't EFAULT.  I'd
> prefer to remove them and simply do memcpy checking.

Folks,

Please don't add extra unneeded checks or fix stuff that does not need
to be fixed. Verify area is not bogus. We need to know total length of
the iovec so we might as well check it in the same loop and not bother
with checking later. 

Thanks
Max
