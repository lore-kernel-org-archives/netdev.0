From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: fix possible null deref in
 xfrm_init_tempstate
Date: Mon, 16 Jan 2017 14:24:09 +0100
Message-ID: <20170116132409.GP3541@gauss.secunet.com>
References: <1484315714-4840-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dan.carpenter@oracle.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38520 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751469AbdAPNYT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 08:24:19 -0500
Content-Disposition: inline
In-Reply-To: <1484315714-4840-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 02:55:14PM +0100, Florian Westphal wrote:
> Dan reports following smatch warning:
>  net/xfrm/xfrm_state.c:659
>  error: we previously assumed 'afinfo' could be null (see line 651)
> 
>  649  struct xfrm_state_afinfo *afinfo = xfrm_state_afinfo_get_rcu(family);
>  651  if (afinfo)
> 		...
>  658  }
>  659  afinfo->init_temprop(x, tmpl, daddr, saddr);
> 
> I am resonably sure afinfo cannot be NULL here.
> 
> xfrm_state4.c and state6.c are both part of ipv4/ipv6 (depends on
> CONFIG_XFRM, a boolean) but even if ipv6 is a module state6.c can't
> be removed (ipv6 lacks module_exit so it cannot be removed).
> 
> The only callers for xfrm6_fini that leads to state backend unregister
> are error unwinding paths that can be called during ipv6 init function.
> 
> So after ipv6 module is loaded successfully the state backend cannot go
> away anymore.
> 
> The family value from policy lookup path is taken from dst_entry, so
> that should always be AF_INET(6).
> 
> However, since this silences the warning and avoids readers of this
> code wondering about possible null deref it seems preferrable to
> be defensive and just add the old check back.
> 
> Fixes: 711059b9752ad0 ("xfrm: add and use xfrm_state_afinfo_get_rcu")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to ipsec-next, thanks!
