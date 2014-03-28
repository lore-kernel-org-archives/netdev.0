From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 3/3] ipv6: fix checkpatch errors of "foo*" and "foo * bar"
Date: Fri, 28 Mar 2014 19:16:57 +0100
Message-ID: <20140328181657.GE11063@order.stressinduktion.org>
References: <1395979624-8544-1-git-send-email-wangyufen@huawei.com> <1395979624-8544-4-git-send-email-wangyufen@huawei.com> <1395980521.19009.8.camel@joe-AO722> <20140328.014012.963819707045886028.davem@davemloft.net> <20140328101704.GD11063@order.stressinduktion.org> <063D6719AE5E284EB5DD2968C1650D6D0F6EB756@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	"joe@perches.com" <joe@perches.com>,
	"wangyufen@huawei.com" <wangyufen@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38003 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbaC1SQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 14:16:59 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EB756@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2014 at 10:54:13AM +0000, David Laight wrote:
> From: Hannes Frederic Sowa
> > > > Perhaps all the __inline__ uses could be changed to inline too.
> > >
> > > Or rather, deleted completely, this is a *.c file after all.
> 
> Personally I wouldn't do a blanket removal of 'inline' from .c files.
> But I will agree that some large functions have been inappropriately
> marked 'inline'.

Does inline keyword actually make a difference in case the function is
static? I guess not (except for function profiling if a prologue should
get included, thus the change in visibility for tracing).

> The complier doesn't always make the right guess.
> 
> > Smart-arsing:
> > 
> > Removing inline keyword makes the function visible to tracing if
> > it didn't get inlined. I think this is a nice side-effect because debug
> > kernels are often compiled with less aggressive inlining options
> > (readable asm kconfig option).
> 
> I want to debug the same binary that will run in production.
> Dodgy code can be affected by all sorts of compiler options.

I agree. But status quo is that your binaries look very different if
you have DEBUG_SECTION_MISMATCH or READABLE_ASM defined.

The change in tracing visibility is already the case if you (like
me) compile your kernel with DEBUG_SECTION_MISMATCH wich enables
no-inline-functions-called-once, because this option does also not
respect inline keyword.

> The best one was a problem with the shell deleting the last
> character of a $(...) substitution.
> The code ran off the beginning of an on-stack buffer when trimming
> trailing '\n' and 'found' a '\n' byte lurking in the unwritten
> stack (this was well down the stack, and had been written much,
> much earlier).
> The error was only ever likely on big-endian systems (the msb of
> a word is less likely to be '\n'.

Heh. :)

Greetings,

  Hannes
