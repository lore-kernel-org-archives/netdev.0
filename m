From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] isdnloop: NUL-terminate strings from userspace
Date: Tue, 1 Apr 2014 13:02:55 +0200
Message-ID: <20140401110255.GH24150@order.stressinduktion.org>
References: <1396346898-8950-1-git-send-email-vegard.nossum@oracle.com> <20140401103020.GG24150@order.stressinduktion.org> <533A990D.2040609@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44048 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbaDALC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 07:02:57 -0400
Content-Disposition: inline
In-Reply-To: <533A990D.2040609@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 01, 2014 at 12:46:37PM +0200, Vegard Nossum wrote:
> On 04/01/2014 12:30 PM, Hannes Frederic Sowa wrote:
> >Looking down the problem, it seems the problem is that the strlen in 
> >strlcpy
> >could read beyond the input buffer?
> >
> >To prevent this problem in other parts of the kernel wouldn't it be better 
> >to
> >replace the strlen with strnlen in strlcpy?
> 
> Sorry, I should have included the link to the previous thread: 
> https://lkml.org/lkml/2014/3/7/712
> 
> I only resent (adding netdev to Cc) to get this into David Miller's 
> patch queue.

Ah ok, sorry I don't follow lkml as closely as netdev@.

> As you can see from the previous discussion, we _could_ change the Linux 
> kernel's definition of strlcpy(), but I wouldn't recommend it for the 
> following reasons:
> 
> 1. Both BSD man page and BSD implementation _require_ the source string 
> to be 0-terminated. Changing the semantics of strlcpy() in the Linux 
> kernel would probably be a bad idea and cause even more confusion that 
> what we already have.

Sure, we shouldn't change the documented semantics. If at all it would
be an additional safety net. Your patch would still be needed.

> 2. Even if we changed strlcpy() to use strnlen(), it would still be 
> unsafe if the source string is not 0-terminated and the source buffer is 
> shorter than the destination buffer. That's because the size passed to 
> strlcpy() is conceptually the length of the _destination_ buffer, not 
> the source string.

Ack.

> I'm not against changing strlcpy() per se (changing to strnlen() might 
> be a performance improvement), but we shouldn't use that as an excuse to 
> use the interface incorrectly.

I am totally with you there.

Actually in some cases it could hinder finding such bugs as we're more
unlikely to hit a RED_ZONE which should crash the kernel (I actually
think crashes to find such bugs are good). But I guess the propability
is pretty high to hit another NUL byte before that and if at that point a
RED_ZONE is mapped.

Thanks,

  Hannes
