From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Mon, 13 Apr 2009 01:31:14 +0200
Message-ID: <7e0dd21a0904121631u3fc7c676r12eb7e71fe87e02b@mail.gmail.com>
References: <1239137800.21227.10.camel@dogo.mojatatu.com>
	 <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com>
	 <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com>
	 <20090412103212.GA28397@ioremap.net>
	 <7e0dd21a0904120423v4296898fl7ce82ec8c3e42d3a@mail.gmail.com>
	 <20090412142451.GA2694@ioremap.net>
	 <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com>
	 <20090412195203.GA11899@ioremap.net>
	 <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com>
	 <20090412205334.GA14345@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:63030 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbZDLXbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2009 19:31:16 -0400
Received: by bwz17 with SMTP id 17so1829657bwz.37
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2009 16:31:14 -0700 (PDT)
In-Reply-To: <20090412205334.GA14345@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Evgeniy,

So if my understanding is correct, there is no way to get original
fragment address in destructor using skb fragment page/data.

Then,
I can't use fragments due to skb_linearize
I can't hide pointer into skb data due to skb_copy.
I can't rely on other fields of skb.
IMHO, using skb pointer requires too much cpu resources (parsing
headers to identify the right buffer...)

So what can I do except using a new field?
What do you think about adding a new field that is always linked to destructor?
I mean adding a generic new field skb->destructor_arg.

Currently if someone want to change destructor, it stores old
destructor before substitution; and executes it at the end of new
destructor. (ex: dev_gso_skb_destructor(struct sk_buff *skb))

Can we just add same mechanism for a new argument?
If someone needs destructor_arg, it saves the old value somewhere; and
restores it before calling old destructor (in the new destructor).
This way everybody can forward data to his destructor properly.

 Is it conceivable?

Thanks for your help,
Johann


-- 
Johann Baudy
johaahn@gmail.com
