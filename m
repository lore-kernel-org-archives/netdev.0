From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 06 Jun 2017 21:19:26 -0700
Message-ID: <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
         <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
         <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
        netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35395 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbdFGET2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 00:19:28 -0400
Received: by mail-pg0-f45.google.com with SMTP id k71so946741pgd.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 21:19:28 -0700 (PDT)
In-Reply-To: <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-06 at 18:34 -0600, David Ahern wrote:
> On 6/6/17 6:27 PM, Eric Dumazet wrote:
> > Good catch, but it looks like similar fix is needed a few lines before.
> > 
> > diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> > index deea901746c8570c5e801e40592c91e3b62812e0..b214443dc8346cef3690df7f27cc48a864028865 100644
> > --- a/net/ipv6/ip6_fib.c
> > +++ b/net/ipv6/ip6_fib.c
> > @@ -372,12 +372,13 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
> >  
> >  		read_lock_bh(&table->tb6_lock);
> >  		res = fib6_walk(net, w);
> > -		read_unlock_bh(&table->tb6_lock);
> >  		if (res > 0) {
> >  			cb->args[4] = 1;
> >  			cb->args[5] = w->root->fn_sernum;
> >  		}
> > +		read_unlock_bh(&table->tb6_lock);
> 
> indeed. tunnel vision on Ben's problem

BTW, bug was already Ben's problem when Patrick tried to fix it
in commit 2bec5a369ee79 ("ipv6: fib: fix crash when changing large fib
while dumping it")  seven years ago ;)
