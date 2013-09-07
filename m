From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: fib: fib6_add: fix potential NULL pointer dereference
Date: Sat, 7 Sep 2013 21:35:57 +0200
Message-ID: <20130907193557.GB17248@order.stressinduktion.org>
References: <1378559600-15858-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Lin Ming <mlin@ss.pku.edu.cn>,
	Matti Vaittinen <matti.vaittinen@nsn.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43647 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab3IGTf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 15:35:58 -0400
Content-Disposition: inline
In-Reply-To: <1378559600-15858-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 07, 2013 at 03:13:20PM +0200, Daniel Borkmann wrote:
> When the kernel is compiled with CONFIG_IPV6_SUBTREES, and we return
> with an error in fn = fib6_add_1(), then error codes are encoded into
> the return pointer e.g. ERR_PTR(-ENOENT). In such an error case, we
> write the error code into err and jump to out, hence enter the if(err)
> condition. Now, if CONFIG_IPV6_SUBTREES is enabled, we check for:
> 
>   if (pn != fn && pn->leaf == rt)
>     ...
>   if (pn != fn && !pn->leaf && !(pn->fn_flags & RTN_RTINFO))
>     ...
> 
> Since pn is NULL and fn is f.e. ERR_PTR(-ENOENT), then pn != fn
> evaluates to true and causes a NULL-pointer dereference on further
> checks on pn. Fix it, by setting both NULL in error case, so that
> pn != fn already evaluates to false and no further dereference
> takes place.
> 
> This was first correctly implemented in 4a287eba2 ("IPv6 routing,
> NLM_F_* flag support: REPLACE and EXCL flags support, warn about
> missing CREATE flag"), but the bug got later on introduced by
> 188c517a0 ("ipv6: return errno pointers consistently for fib6_add_1()").
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Lin Ming <mlin@ss.pku.edu.cn>
> Cc: Matti Vaittinen <matti.vaittinen@nsn.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Full ACK!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
