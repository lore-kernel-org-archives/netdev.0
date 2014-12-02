From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH] netfilter: conntrack: cache route for forwarded
 connections
Date: Tue, 2 Dec 2014 09:15:32 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412020827260.1593@ja.home.ssi.bg>
References: <1417480114-3002-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, brouer@redhat.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52314 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754059AbaLBHPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 02:15:49 -0500
In-Reply-To: <1417480114-3002-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 2 Dec 2014, Florian Westphal wrote:

> ... to avoid per-packet FIB lookup if possible.
> 
> The cached dst is re-used provided the input interface
> is the same as that of the previous packet in the same direction.
> 
> If not, the cached dst is invalidated.
> 
> This should speed up forwarding when conntrack is already in use
> anyway, especially when using reverse path filtering -- active RPF
> enforces two FIB lookups for each packet.
> 
> Before the routing cache removal this didn't matter since RPF
> was performed only when route cache didn't yield a result; but without
> route cache it comes at high price.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Sending as RFC since I haven't tested this yet (aside from
>  single-forwarded-flow), so no performance data either.
> 
>   - doesn't work when iif changes (it invalidates cached dst), don't
>   think its a problem

	The idea is good. But code that caches dsts should
also handle at least NETDEV_UNREGISTER (NETDEV_DOWN being
another option) to release dsts. Holding dsts for frozen
conns in EST state for long time is a problem. IIRC, such dsts
are not under dst_dev_event() control. nf_nat_masquerade_ipv4.c
has something like this but for masq_index.

Regards

--
Julian Anastasov <ja@ssi.bg>
