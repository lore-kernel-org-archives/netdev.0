From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 11:22:27 +0200
Message-ID: <1335432147.2775.27.camel@edumazet-glaptop>
References: <1335427854.2775.15.camel@edumazet-glaptop>
	 <20120426.043623.1317043382565428400.davem@davemloft.net>
	 <1335431402.2775.24.camel@edumazet-glaptop>
	 <20120426.051800.637617874638567499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, rick.jones2@hp.com,
	netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	maze@google.com, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53526 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab2DZJWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:22:33 -0400
Received: by eekc41 with SMTP id c41so527971eek.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 02:22:31 -0700 (PDT)
In-Reply-To: <20120426.051800.637617874638567499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 05:18 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 26 Apr 2012 11:10:02 +0200
> 
> > The 'frag' would have a known size : 2048 bytes
> > 
> > But the end of it would be used by struct skb_shared_info
> > 
> > so data_len would be 0 in fact.
> > 
> > This would look like a regular linear skb.
> > 
> > Just a bit set in skb to say : Warning, skb->head was not kmalloced :
> > replace kfree(head) by put_page(...)
> > 
> > And this bit would be tested in GRO or tcp merge to 'upgrade' this
> > skb->head to proper page/frag
> 
> And what happens if this ends up in a piece of code which wants to
> append a page frag?
> 
> Or a piece of code which copies an SKB, including page frag parts?
> 
> All I'm saying is that the number of tests necessary to make this work
> properly might become prohibitive.

I'll cook a patch, I believe not so many parts assume skb->head can be
kmalloc()/kfree(). This should be contained in net/core/skbuff.c only.

Elsewhere we use skb->head as a pointer to memory. It will stay the
same.
