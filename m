From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Tue, 18 Nov 2014 21:23:07 +0000
Message-ID: <20141118212307.GU7996@ZenIV.linux.org.uk>
References: <20141118084745.GT7996@ZenIV.linux.org.uk>
 <CA+55aFxK0wj2LLp0WmhRsBZch8XfoYbzmbEeJaMpt=SDh5GBvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxK0wj2LLp0WmhRsBZch8XfoYbzmbEeJaMpt=SDh5GBvw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2014 at 12:49:13PM -0800, Linus Torvalds wrote:
> On Tue, Nov 18, 2014 at 12:47 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > The minimal implementations would be
> >
> > __wsum csum_and_copy_from_user(const void __user *src, void *dst, int len,
> >                                __wsum sum, int *err_ptr)
> > {
> >         if (unlikely(copy_from_user(dst, src, len) < 0)) {
> 
> No. That "< 0" should be "!= 0". The user copy functions return a
> positive value of how many bytes they *failed* to copy.

D'oh...  Yes, indeed - sorry about the braino.

> > IMO the calling conventions are atrocious.
> 
> Yeah, not pretty. At the same time, the pain of changing what seems to
> work might not be worth it.
> 
> And quite frankly, I *detest* your patch 3/5.
> 
> "access_ok()" isn't that expensive, and removing them as unnecessary
> is fraught with errors. We've had several cases of "oops, we used
> __get_user() in a loop, because it generates much better code, but
> we'd forgotten to do access_ok(), so now people can read kernel data".

OK...  If netdev folks can live with that for now, I've no problem with
dropping 3/5.  However, I really think we need a variant of csum-and-copy
that would _not_ bother with access_ok() longer term.  That can wait, though...
