From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 15:16:49 +0200
Message-ID: <7e0dd21a0904210616o7bdbebc2p8ed29b47ac573e34@mail.gmail.com>
References: <20090412142451.GA2694@ioremap.net>
	 <20090412195203.GA11899@ioremap.net>
	 <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com>
	 <20090412205334.GA14345@ioremap.net>
	 <7e0dd21a0904121631u3fc7c676r12eb7e71fe87e02b@mail.gmail.com>
	 <20090415071023.GA26986@ioremap.net>
	 <7e0dd21a0904150614y301a01e4rdec1fe4f9a14c13f@mail.gmail.com>
	 <20090416111616.GB28509@ioremap.net>
	 <7e0dd21a0904181438j251f4f8cnc210c6dee8ce5212@mail.gmail.com>
	 <20090421094149.GA22907@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:42101 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090AbZDUNQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 09:16:51 -0400
Received: by fxm2 with SMTP id 2so2511511fxm.37
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 06:16:49 -0700 (PDT)
In-Reply-To: <20090421094149.GA22907@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,
> It cals skb_release_data() which should invoke shared area destructor
> before being freed.

Yes but in this case, it will be called twice, as shared info (that
contains destructor) is memcopied to new expanded head.
shared info destructor will be excuted two times on "same" data
(during skb_expand_head() and during kfree_skb())
Actually, I want to know if this behavior is intended with a new
shared info destructor.

Thanks
-- 
Johann Baudy
