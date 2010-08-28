From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sat, 28 Aug 2010 16:31:32 +0200
Message-ID: <20100828143132.GA3211@del.dom.local>
References: <20100827205042.GA13844@del.dom.local>
 <20100828001337.GA1955@gondor.apana.org.au>
 <20100828094433.GA3110@del.dom.local>
 <1282992846.2277.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58807 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485Ab0H1Obi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 10:31:38 -0400
Received: by fxm13 with SMTP id 13so2522103fxm.19
        for <netdev@vger.kernel.org>; Sat, 28 Aug 2010 07:31:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1282992846.2277.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 28, 2010 at 12:54:06PM +0200, Eric Dumazet wrote:
> In commit f2bde7328633269ee935d9ed96535ade15cc348f
> Author: Stephen Hemminger <shemminger@vyatta.com>
> 
>     net: allow multiple dev per napi with GRO
>     
>     GRO assumes that there is a one-to-one relationship between NAPI
>     structure and network device. Some devices like sky2 share multiple
>     devices on a single interrupt so only have one NAPI handler. Rather than
>     split GRO from NAPI, just have GRO assume if device changes that
>     it is a different flow.
>    
> 
> It was assumed a napi could be shared by several devs, but I dont really
> understand, since we have an unique ->dev pointer inside "napi_struct",
> this one is set once, and never change.
> 
> This pointer is currently used from napi_get_frags() [but that could be
> avoided], and from netpoll_poll_lock().
> 
> The netpoll_poll_lock() case is problematic.
> 
> static inline void *netpoll_poll_lock(struct napi_struct *napi)
> {
>         struct net_device *dev = napi->_dev;
> 
>         if (dev && dev->npinfo) {
>                 spin_lock(&napi->poll_lock);
> 
> Maybe we should remove 'dev' field from napi_struct and replace it by a
> npinfo pointer ?

Sky2 seems to work like a single netdev (with an internal sub-netdev),
so I can't see your concern: what is the main aim of this replacement?

Jarek P. 
