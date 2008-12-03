From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 05/39] wimax: debug macros and debug settings for the WiMAX stack
Date: Tue, 2 Dec 2008 18:07:44 -0800
Message-ID: <200812021807.45252.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <ff25717bf78b6831db361b925f7081d5d6faf876.1227691434.git.inaky@linux.intel.com> <1227778088.3809.13.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:5961 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753978AbYLCCLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:31 -0500
In-Reply-To: <1227778088.3809.13.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> > This file contains a simple debug framework that is used in the stack;
>
>                        ^^^^^ ??
>
> > it allows the debug level to be controlled at compile-time (so the
> > debug code is optimized out) and at run-time (for what wasn't compiled
> > out).
>
> Recently we got new stuff for dynamic printk
> (include/linux/dynamic_printk.h) and pr_debug with a start format
> (include/linux/kernel.h, pr_fmt); can you use any of that to make this
> smaller? If not, I think you ought to argue why not, and possibly
> improve the generic facility.

Yep, it was just too recent. I hadn't noticed it and I was told about
it a week ago. I just need to map it. It's on my plan to change it,
but I don't know if I'll have to do it for the push.

> Personally, I'm tired of seeing every Intel driver come with a new huge
> set of debugging macros that are barely understandable.

me too -- I am glad there is finally a common facility in the kernel
for it. 

> > +#define _d_printf(l, tag, dev, f, a...)					\
> > +do {									\
> > +	char head[64];							\
> > +	if (!d_test(l))							\
> > +		break;							\
> > +	__d_head(head, sizeof(head), dev);				\
> > +	printk(KERN_ERR "%s%s%s: " f, head, __func__, tag, ##a);	\
> > +} while (0 && dev)
>
> That && dev is wrong.

Another remnant from a previous implementation -- killed, thanks

-- 
Inaky

