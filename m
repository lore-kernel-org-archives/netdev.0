From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Sat, 18 Apr 2009 23:38:48 +0200
Message-ID: <7e0dd21a0904181438j251f4f8cnc210c6dee8ce5212@mail.gmail.com>
References: <20090412103212.GA28397@ioremap.net>
	 <20090412142451.GA2694@ioremap.net>
	 <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com>
	 <20090412195203.GA11899@ioremap.net>
	 <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com>
	 <20090412205334.GA14345@ioremap.net>
	 <7e0dd21a0904121631u3fc7c676r12eb7e71fe87e02b@mail.gmail.com>
	 <20090415071023.GA26986@ioremap.net>
	 <7e0dd21a0904150614y301a01e4rdec1fe4f9a14c13f@mail.gmail.com>
	 <20090416111616.GB28509@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:63655 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757487AbZDRViu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 17:38:50 -0400
Received: by fxm2 with SMTP id 2so1381856fxm.37
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 14:38:49 -0700 (PDT)
In-Reply-To: <20090416111616.GB28509@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think it should only be called when shared area is about to be freed
> and not when attached skb is freed.
During skb_linearize(). shared info is memcopied and freed in
pskb_expand_head() if not enough memory is available in current head.
Then, Do you expect this new destructor to be called twice? (during
skb_linearize() and kfree_skb())

>Thus you can put your pages into
> fraglist and reuse them after the last reference to the shared area is
> gone.

If my understanding is correct, skb can be linearized without calling
skb_release_data() (if enough space is available in head). Hence, In
this case, I will not have access to original frags[] from
skb_shared_info destructor.

Thanks again,
Johann
