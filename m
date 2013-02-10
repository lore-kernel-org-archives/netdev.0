From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH] skbuff: create skb_panic() to let caller specify panic
Date: Sat, 9 Feb 2013 22:56:29 -0700
Message-ID: <20130210055629.GB2496@mail.gmail.com>
References: <1360471749-6177-1-git-send-email-sakiwit@gmail.com>
 <1360473061.26127.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:50880 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab3BJF5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 00:57:10 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so295966pbc.10
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 21:57:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360473061.26127.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 09 Feb 2013 21:11:01 -0800
>
> On Sat, 2013-02-09 at 21:49 -0700, Jean Sacren wrote:
> > Combine skb_over_panic() and skb_under_panic() into skb_panic() and let
> > the caller specify whether it is skb_over_panic or skb_under_panic.
> []
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> []
> > @@ -104,48 +104,28 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
> []
> > -static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
> > +static void skb_panic(struct sk_buff *skb, unsigned int size, void *addr,
> > +		      const char panic[])
> >  {
> > -	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx dev:%s\n",
> > -		 __func__, here, skb->len, sz, skb->head, skb->data,
> > +	pr_emerg("%s: text:%p len:%d put:%d head:%p data:%p tail:%#lx "
> > +		 "end:%#lx dev:%s\n",
> 
> Trivia:
> 
> Don't split the format across multiple lines please.

Thank you for reviewing.

Honestly I didn't want to split the whole string, but I was in the
dilemma of accommodating 80-column convention. I'm ready to respin if
the consensus favors one long string. But how long is too long?

-- 
Jean Sacren
