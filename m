From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 7 Jul 2013 14:27:54 -0700
Message-ID: <CA+55aFzgBXwye=ebPmEDN_6yqdKA6ZaD9hSUzbFjSacC_v3y5g@mail.gmail.com>
References: <20130707.132133.1335860703202153192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:54365 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170Ab3GGV14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jul 2013 17:27:56 -0400
In-Reply-To: <20130707.132133.1335860703202153192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 7, 2013 at 1:21 PM, David Miller <davem@davemloft.net> wrote:
>
> 5) arch/arm/mach-mxs/Kconfig
>
>    Overlapping additions of select statements for SOC_IMX2.

Nope. Removals.

> 6) arch/arm/mach-mxs/mach-mxs.c
>
>    In mxs_machine_init(), the of_platform_populate() call has it's final
>    two arguments changed to be NULL.

Hmm. That's not how I read it. The next-to-last argument in changed to
NULL in one branch, the other adds "parent".

> 11) fs/select.c
>
>     Overlapping additions of include directives, keep both.

This LL_POLL thing is ugly as hell. Where was this discussed?
Apparently on lkml without talking to people who are actually involved
in select/poll.

I'm not at all sure I want to pull this kind of crap without having
seen the full discussion, and the performance numbers are kind of
pointless without also talking about CPU utilization etc. Since when
is it ok to start doing things like this without any acks from anybody
else?

Because quite frankly, the fs/select.c changes make me go: "No way in
hell". Partly because of the idiotic and completely undescriptive
naming, partly because of the disgisting calling convetions with
random flags variables passed in to be changed be helper functions.

So no, I'm not pulling this. Things like this need discussion and
heads-up, not just random "let's add completely ugly things to core
kernel functionality without even asking people".

Even the commit messages in question are just PURE AND UTTER CRAP. Ask
yourself honestly what the F*CK this means:

  net: convert lls to use time_in_range

what the hell, David? What diseased mind uses idiotic short-hand like
this that makes no sense? And dammit, I'd expect the VFS people to be
cc'd on changes to the VFS layer functions. I wasn't, Al wasn't.

So not pulled. Fix up this mess.

               Linus
