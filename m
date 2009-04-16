From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Thu, 16 Apr 2009 15:16:16 +0400
Message-ID: <20090416111616.GB28509@ioremap.net>
References: <20090412103212.GA28397@ioremap.net> <7e0dd21a0904120423v4296898fl7ce82ec8c3e42d3a@mail.gmail.com> <20090412142451.GA2694@ioremap.net> <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com> <20090412195203.GA11899@ioremap.net> <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com> <20090412205334.GA14345@ioremap.net> <7e0dd21a0904121631u3fc7c676r12eb7e71fe87e02b@mail.gmail.com> <20090415071023.GA26986@ioremap.net> <7e0dd21a0904150614y301a01e4rdec1fe4f9a14c13f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:35558 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881AbZDPLQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 07:16:18 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0904150614y301a01e4rdec1fe4f9a14c13f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 03:14:22PM +0200, Johann Baudy (johann.baudy@gnu-log.net) wrote:
> +void                    (*destructor)(struct sk_buff *skb, void *
> destructor_arg);
> +void * destructor_arg;
> };
> 
> Should I call this new destructor from skb_release_data() before
> kfree(skb->head) ?
> or in  skb_release_head_state()? close to current destructor call

I think it should only be called when shared area is about to be freed
and not when attached skb is freed. Thus you can put your pages into
fraglist and reuse them after the last reference to the shared area is
gone.

-- 
	Evgeniy Polyakov
