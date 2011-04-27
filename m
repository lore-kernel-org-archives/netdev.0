From: Lifeng Sun <lifongsun@gmail.com>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket should
 return ENOTTY
Date: Wed, 27 Apr 2011 16:22:24 +0800
Message-ID: <20110427082224.GC20313@md5.ntu.edu.sg>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
 <1303883910.2699.53.camel@edumazet-laptop>
 <20110427063730.GA20313@md5.ntu.edu.sg>
 <1303887457.2699.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1303887457.2699.60.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08:57 Wed 04/27/11 Apr, Eric Dumazet wrote:
> You quote manpage for a library call, not a system call.

okay, let me quote the one for ioctl system call:

man 2 ioctl

int ioctl(int d, int request, ...);

ERRORS
   EBADF  d is not a valid descriptor.
   EFAULT argp references an inaccessible memory area.
   EINVAL Request or argp is not valid.
   ENOTTY d is not associated with a character special device.
   ENOTTY The specified request does not apply to the kind of object
     that the descriptor d references.

we see ENOTTY and EFAULT refine EVINAL and it should return ENOTTY or
EFAULT whenever possible rather than EINVAL, otherwise we could always
return EBADF or EINVAL.

Regarding to isatty, well, it's only a library call, isn't it? :-) If
you insist on the significance of the manpage of isatty, there are
also a lot of ioctl operations return ENOTTY, if not less than those
return EINVAL, for inappropriated command and eventually violate the
ERRORS section of the manpage. Certainly we could complain to c
library maintainers.


> If you feel your glibc doesnt implement well this, please complain to
> glibc maintainer.


-- 
