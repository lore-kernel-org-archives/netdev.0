From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] crypto: ccm - avoid scatterlist for MAC encryption
Date: Mon, 17 Oct 2016 09:47:58 +0200
Message-ID: <1476690478.19992.4.camel@sipsolutions.net>
References: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org>
         <1476689310.19992.1.camel@sipsolutions.net>
         <CAKv+Gu_P-6sHW3t7tp1N+3v9ZGqWcQrzMZkASY5g=QR76KN4wg@mail.gmail.com>
         (sfid-20161017_093746_906697_1D2C1C61)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Andy Lutomirski <luto@amacapital.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49102 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933019AbcJQHsG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 03:48:06 -0400
In-Reply-To: <CAKv+Gu_P-6sHW3t7tp1N+3v9ZGqWcQrzMZkASY5g=QR76KN4wg@mail.gmail.com> (sfid-20161017_093746_906697_1D2C1C61)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-17 at 08:37 +0100, Ard Biesheuvel wrote:
> 
> Could we get a statement first whether it is supported to allocate
> aead_req (and other crypto req structures) on the stack? 

Well, we haven't heard from Herbert :)

> If not, then
> we have our work cut out for us. But if it is, I'd rather we didn't
> apply the kzalloc/kfree patch, since it is just a workaround for the
> broken generic CCM driver, for which a fix is already available.

Yeah but I can't apply it. I just fixed up your kzalloc patch to also
handle GCM and GMAC, and to have error checking. Will send it in a
minute.

> Also, regarding your __percpu patch: those are located in the vmalloc
> area as well, at least on arm64, and likely other architectures too.

Crap. Any other bright ideas?

johannes
