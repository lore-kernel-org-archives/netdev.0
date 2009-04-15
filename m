From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Wed, 15 Apr 2009 11:10:23 +0400
Message-ID: <20090415071023.GA26986@ioremap.net>
References: <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com> <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com> <20090412103212.GA28397@ioremap.net> <7e0dd21a0904120423v4296898fl7ce82ec8c3e42d3a@mail.gmail.com> <20090412142451.GA2694@ioremap.net> <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com> <20090412195203.GA11899@ioremap.net> <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com> <20090412205334.GA14345@ioremap.net> <7e0dd21a0904121631u3fc7c676r12eb7e71fe87e02b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:49963 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbZDOHKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 03:10:33 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0904121631u3fc7c676r12eb7e71fe87e02b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Mon, Apr 13, 2009 at 01:31:14AM +0200, Johann Baudy (johann.baudy@gnu-log.net) wrote:
> So if my understanding is correct, there is no way to get original
> fragment address in destructor using skb fragment page/data.
> 
> Then,
> I can't use fragments due to skb_linearize
> I can't hide pointer into skb data due to skb_copy.
> I can't rely on other fields of skb.
> IMHO, using skb pointer requires too much cpu resources (parsing
> headers to identify the right buffer...)
> 
> So what can I do except using a new field?
> What do you think about adding a new field that is always linked to destructor?
> I mean adding a generic new field skb->destructor_arg.

It can work but do not place it into skb itself, but into shared area,
which is slab allocated and does not suffer from size restrictions.
You can also add shared-info destructor, which could be used by other

-- 
	Evgeniy Polyakov
