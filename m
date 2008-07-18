From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 12:15:26 +0300
Message-ID: <84144f020807180215p4c3e9fadl75c478f1aacea35f@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <20080718054626.GA3338@2ka.mipt.ru>
	 <84144f020807180202l6c703234ic3a2b57e73a1d89a@mail.gmail.com>
	 <20080718090951.GP6875@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Vegard Nossum" <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:44193 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbYGRJP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 05:15:27 -0400
Received: by rv-out-0506.google.com with SMTP id k40so258521rvb.1
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 02:15:26 -0700 (PDT)
In-Reply-To: <20080718090951.GP6875@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ingo,

On Fri, Jul 18, 2008 at 12:09 PM, Ingo Molnar <mingo@elte.hu> wrote:
> yeah, we want to check use-after free at the next allocation point -
> i.e. as late as possible to gather all corruptions that happened
> meanwhile.
>
> We could in theory have a SLUB debug mode where a SCHED_IDLE kernel
> thread would periodically check all free objects (of that CPU) in the
> background to ensure their integrity. That would catch corruptions
> sooner, with a possibly still meaningful context to print out. [right
> after the IRQ or process that corrupts them finishes running]
>
> It could also be hooked into ftrace to print out the last few hundred
> kernel function calls executed prior any corruption. ftrace/slub-debug
> plugin perhaps?

Well, there's this Norwegian guy, Vegard, who has written a small
piece of code that can detect use-after-free _as it happens_. I think
he calls the thing kmemcheck :-).
