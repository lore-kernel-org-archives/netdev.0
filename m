From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Wed, 15 Apr 2009 15:14:22 +0200
Message-ID: <7e0dd21a0904150614y301a01e4rdec1fe4f9a14c13f@mail.gmail.com>
References: <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com>
	 <20090412103212.GA28397@ioremap.net>
	 <7e0dd21a0904120423v4296898fl7ce82ec8c3e42d3a@mail.gmail.com>
	 <20090412142451.GA2694@ioremap.net>
	 <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com>
	 <20090412195203.GA11899@ioremap.net>
	 <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com>
	 <20090412205334.GA14345@ioremap.net>
	 <7e0dd21a0904121631u3fc7c676r12eb7e71fe87e02b@mail.gmail.com>
	 <20090415071023.GA26986@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:40608 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbZDONOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 09:14:24 -0400
Received: by fxm2 with SMTP id 2so2903439fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 06:14:22 -0700 (PDT)
In-Reply-To: <20090415071023.GA26986@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your reply, Evgeniy,

> It can work but do not place it into skb itself, but into shared area,
> which is slab allocated and does not suffer from size restrictions.
Ok

> You can also add shared-info destructor, which could be used by other
Kind of:
struct skb_shared_info {
         atomic_t        dataref;
....
+void                    (*destructor)(struct sk_buff *skb, void *
destructor_arg);
+void * destructor_arg;
};

Should I call this new destructor from skb_release_data() before
kfree(skb->head) ?
or in  skb_release_head_state()? close to current destructor call

Best regards,
Johann

-- 
Johann Baudy
johaahn@gmail.com
