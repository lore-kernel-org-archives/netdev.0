From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: suppress too verbose messages in
 tcp_send_ack()
Date: Wed, 25 Nov 2015 19:29:39 -0800
Message-ID: <1448508579.24696.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <f7t7fl5g2ao.fsf@aconole.bos.csb>
	 <1448490758.24696.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448490937.24696.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <f7t7fl51mau.fsf@aconole.bos.csb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Aaron Conole <aconole@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32802 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbbKZD3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 22:29:41 -0500
Received: by pabfh17 with SMTP id fh17so78706450pab.0
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 19:29:41 -0800 (PST)
In-Reply-To: <f7t7fl51mau.fsf@aconole.bos.csb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-25 at 22:17 -0500, Aaron Conole wrote:

> Probably that would call for a different more primitive version of this
> API (sk_gfp_or_memalloc() as you suggest below). Then this could be
> written in terms of that
> 
> static inline sk_gfp_or_memalloc(const struct sock *sk, gfp_t gfp_mask)
> {
> 	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
> }
> 
> static inline sk_gfp_atomic(const struct sock *sk, gfp_t gfp_mask)
> {
> 	return sk_gfp_or_memalloc(sk, gfp_mask | GFP_ATOMIC);
> }
> 
> Not sure if it's "too much API".

Well, this looks like it, not sure how this is going to make code
clearer.

The only thing we bring from sk is the __GFP_MEMALLOC thing, so a single
function seems enough ?

I honestly do not care that much about function names, I mostly look at
actual implementation. And current implementation ignores the gfp_t
gfp_mask argument, for no real good reason.
