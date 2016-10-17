From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] crypto: ccm - avoid scatterlist for MAC encryption
Date: Mon, 17 Oct 2016 09:57:39 +0200
Message-ID: <1476691059.19992.6.camel@sipsolutions.net>
References: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org>
         <1476689310.19992.1.camel@sipsolutions.net>
         <CAKv+Gu_P-6sHW3t7tp1N+3v9ZGqWcQrzMZkASY5g=QR76KN4wg@mail.gmail.com>
         <1476690478.19992.4.camel@sipsolutions.net>
         <CAKv+Gu9EPAF+Oihz0tXCqWURGom-wgSPCMp0dEHHnxqw-pYYJw@mail.gmail.com>
         (sfid-20161017_095011_197525_132B0910)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKv+Gu9EPAF+Oihz0tXCqWURGom-wgSPCMp0dEHHnxqw-pYYJw@mail.gmail.com> (sfid-20161017_095011_197525_132B0910)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-10-17 at 08:50 +0100, Ard Biesheuvel wrote:

> I just realised that patch should probably use
> aead_request_alloc/aead_request_free [and drop the memset]. That also
> fixes the latent bug where the alignment of the req ctx is not take
> into account.

Good point, I'll fix that up.

> > 
> > > 
> > > Also, regarding your __percpu patch: those are located in the
> > > vmalloc
> > > area as well, at least on arm64, and likely other architectures
> > > too.
> > 
> > Crap. Any other bright ideas?
> > 
> 
> kmem_cache_create() and kmem_cache_alloc()

for the aad/b0/j0/etc? Hmm. Yeah I guess we should do those dynamically
as well then.

johannes
