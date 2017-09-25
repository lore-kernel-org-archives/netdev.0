From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sch_netem: faster rb tree removal
Date: Sun, 24 Sep 2017 22:27:20 -0700
Message-ID: <1506317240.6617.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1506190048.29839.206.camel@edumazet-glaptop3.roam.corp.google.com>
         <b175f7ab-12b6-061a-4233-ba53641ef99b@gmail.com>
         <aa146e80-4cfd-888f-f6d2-bf4ec0eb7373@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:51519 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753273AbdIYF1Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 01:27:24 -0400
Received: by mail-io0-f173.google.com with SMTP id l15so8703749iol.8
        for <netdev@vger.kernel.org>; Sun, 24 Sep 2017 22:27:23 -0700 (PDT)
In-Reply-To: <aa146e80-4cfd-888f-f6d2-bf4ec0eb7373@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-09-24 at 20:05 -0600, David Ahern wrote:
> On 9/24/17 7:57 PM, David Ahern wrote:

> > Hi Eric:
> > 
> > I'm guessing the cost is in the rb_first and rb_next computations. Did
> > you consider something like this:
> > 
> >         struct rb_root *root
> >         struct rb_node **p = &root->rb_node;
> > 
> >         while (*p != NULL) {
> >                 struct foobar *fb;
> > 
> >                 fb = container_of(*p, struct foobar, rb_node);
> >                 // fb processing
> 		  rb_erase(&nh->rb_node, root);
> 
> >                 p = &root->rb_node;
> >         }
> > 
> 
> Oops, dropped the rb_erase in my consolidating the code to this snippet.

Hi David

This gives about same numbers than method_1

I tried with 10^7 skbs in the tree :

Your suggestion takes 66ns per skb, while the one I chose takes 37ns per
skb.

Thanks.
