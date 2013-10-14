From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH 2/3] net: bpf jit: x86: optimize choose_load_func error
 path
Date: Mon, 14 Oct 2013 04:55:39 +0200
Message-ID: <20131014025535.GA1870@hp530>
References: <1381249910-17338-2-git-send-email-murzin.v@gmail.com>
 <1381676065-2373-1-git-send-email-murzin.v@gmail.com>
 <1381676065-2373-2-git-send-email-murzin.v@gmail.com>
 <1381682194.3392.42.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	av1474@comtv.ru
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:51188 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655Ab3JNC4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 22:56:35 -0400
Received: by mail-lb0-f182.google.com with SMTP id c11so5325454lbj.27
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 19:56:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1381682194.3392.42.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 09:36:34AM -0700, Eric Dumazet wrote:
> On Sun, 2013-10-13 at 16:54 +0200, Vladimir Murzin wrote:
> > Macro CHOOSE_LOAD_FUNC returns handler for "any offset" if checks for K
> > were not passed. At the same time handlers for "any offset" cases make
> > the same checks against r_addr at run-time, that will always lead to
> > bpf_error.
> > 
> > Run-time checks are still necessary for indirect load operations, but
> > error path for absolute and mesh loads are worth to optimize during bpf
> > compile time.
> 
> I don't get the point.
> 
> What real world use case or problem are you trying to handle ?
> 
> bpf_error returns 0, so it seems your patch does the same.
> 
> A buggy BPF program should not expect us to 'save' a few cycles.
> 
> 
> 

Hi Eric!

There is no real world use case for me - it was eliminated by plain code
reading. The patch is not supposed to change behavior of BPF program - only
optimization of the error path. 
I agree with, you there is no significant reason for optimizations of rarely
used pice of code. However, it is not only saving pipeline cycles and I-cache
lines for usually "never taken" branch. In case this "never taken" branch is a
buggy part of BPF program, we can avoid extra instructions and save space for
the rest of BPF program - there is no need to care about seen flags of buggy
part anymore.

Anyway, if you still think it's not good enough - just throw it away ;)

Thanks
Vladimir
