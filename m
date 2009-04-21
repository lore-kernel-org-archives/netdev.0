From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 17:56:27 +0400
Message-ID: <20090421135627.GA1945@ioremap.net>
References: <20090412195203.GA11899@ioremap.net> <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com> <20090412205334.GA14345@ioremap.net> <7e0dd21a0904121631u3fc7c676r12eb7e71fe87e02b@mail.gmail.com> <20090415071023.GA26986@ioremap.net> <7e0dd21a0904150614y301a01e4rdec1fe4f9a14c13f@mail.gmail.com> <20090416111616.GB28509@ioremap.net> <7e0dd21a0904181438j251f4f8cnc210c6dee8ce5212@mail.gmail.com> <20090421094149.GA22907@ioremap.net> <7e0dd21a0904210616o7bdbebc2p8ed29b47ac573e34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:60772 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbZDUN4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 09:56:36 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0904210616o7bdbebc2p8ed29b47ac573e34@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 03:16:49PM +0200, Johann Baudy (johann.baudy@gnu-log.net) wrote:
> Yes but in this case, it will be called twice, as shared info (that
> contains destructor) is memcopied to new expanded head.
> shared info destructor will be excuted two times on "same" data
> (during skb_expand_head() and during kfree_skb())
> Actually, I want to know if this behavior is intended with a new
> shared info destructor.

It depends on your task... You can always store a pointer in the
tree/hash and check it in the destructor, you can play some games in the
expand helper not to call destructor: like messing with the reference
counter and reusing the old area, or silently freeing old area without
destruction invocation (presumably with some new helper).

Moreover you can allocate skb so that no matter what but it could not be
reused by the underlying layers, so it could be fully copied. In this
case usual destructor is enough.

-- 
	Evgeniy Polyakov
