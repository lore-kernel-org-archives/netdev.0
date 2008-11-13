From: "Alexey Dobriyan" <adobriyan@gmail.com>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Fri, 14 Nov 2008 01:53:26 +0300
Message-ID: <b6fcc0a0811131453l4c111135p7b58453a533693ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:21267 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbYKMWx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 17:53:27 -0500
Received: by ey-out-2122.google.com with SMTP id 6so482862eyi.37
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 14:53:26 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2008 at 04:24:23AM -0800, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Wed, 12 Nov 2008 15:24:48 +0300
>
> > +static inline void ib_net_set(struct inet_bind_bucket *ib, struct net *net)
> > +{
> > +#ifdef CONFIG_NET_NS
> > +   ib->ib_net = net;
> > +#endif
> > +}
> > +
>
> It's basically read_pnet() hidden behind another name.
> And you'll add new "aliases" for read_pnet() over and over
> again.
>
> That makes no sense to me.

It also make no sense to expose write_pnet() for one(!) user and
simultaneously hide read_pnet() under ib_net() as committed patches do.

Something is wrong with read_pnet() as nobody suggested to mass use it
or send a patch doing it.


        #ifdef CONFIG_NET_NS
                ib->ib_net = net;
        #endif

It's _obvious_ from this code that it's a C assignment or nop. It's also
obvious depending on what config option.

        write_pnet(&ib->ib_net, net);

What is & operator doing here? Is it important? '&' is syntaxic noise.

And netns assignments are exactly this: assigment or a nop.
