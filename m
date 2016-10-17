From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] crypto: ccm - avoid scatterlist for MAC encryption
Date: Mon, 17 Oct 2016 08:50:09 +0100
Message-ID: <CAKv+Gu9EPAF+Oihz0tXCqWURGom-wgSPCMp0dEHHnxqw-pYYJw@mail.gmail.com>
References: <1476551776-8099-1-git-send-email-ard.biesheuvel@linaro.org>
 <1476689310.19992.1.camel@sipsolutions.net> <CAKv+Gu_P-6sHW3t7tp1N+3v9ZGqWcQrzMZkASY5g=QR76KN4wg@mail.gmail.com>
 <1476690478.19992.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476690478.19992.4.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17 October 2016 at 08:47, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Mon, 2016-10-17 at 08:37 +0100, Ard Biesheuvel wrote:
>>
>> Could we get a statement first whether it is supported to allocate
>> aead_req (and other crypto req structures) on the stack?
>
> Well, we haven't heard from Herbert :)
>
>> If not, then
>> we have our work cut out for us. But if it is, I'd rather we didn't
>> apply the kzalloc/kfree patch, since it is just a workaround for the
>> broken generic CCM driver, for which a fix is already available.
>
> Yeah but I can't apply it. I just fixed up your kzalloc patch to also
> handle GCM and GMAC, and to have error checking. Will send it in a
> minute.
>

I just realised that patch should probably use
aead_request_alloc/aead_request_free [and drop the memset]. That also
fixes the latent bug where the alignment of the req ctx is not take
into account.

>> Also, regarding your __percpu patch: those are located in the vmalloc
>> area as well, at least on arm64, and likely other architectures too.
>
> Crap. Any other bright ideas?
>

kmem_cache_create() and kmem_cache_alloc()
