From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC PATCH 4.10 1/6] crypto/sha256: Refactor the API so it can be
 used without shash
Date: Mon, 26 Dec 2016 10:08:48 -0800
Message-ID: <CALCETrXFTQ2AXgbQzPnRcDRHK81=FS1R0zqfoTqGjUsqZy2PvQ@mail.gmail.com>
References: <cover.1482545792.git.luto@kernel.org> <942b91f25a63b22ec4946378a1fffe78d655cf18.1482545792.git.luto@kernel.org>
 <CAKv+Gu-UCqwchgbhg8VN4s=Yxk=PkjXG46NZo=8P4wAQtJ2TXw@mail.gmail.com>
 <CALCETrVbT_1=cdU1+a-+KbhoFqeT3XvbHjY0s_U7C5JVgiPx_Q@mail.gmail.com>
 <20161226075757.GA8916@gondor.apana.org.au> <CAKv+Gu-NMNCEs61f4k7JSf9iSJ1A_Gy1r=kZRGqtbDsEDz7--Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:34802 "EHLO
        mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755541AbcLZSKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 13:10:43 -0500
Received: by mail-vk0-f44.google.com with SMTP id x186so202556588vkd.1
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2016 10:09:10 -0800 (PST)
In-Reply-To: <CAKv+Gu-NMNCEs61f4k7JSf9iSJ1A_Gy1r=kZRGqtbDsEDz7--Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 26, 2016 at 9:51 AM, Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
> On 26 December 2016 at 07:57, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> On Sat, Dec 24, 2016 at 09:57:53AM -0800, Andy Lutomirski wrote:
>>>
>>> I actually do use incremental hashing later on.   BPF currently
>>> vmallocs() a big temporary buffer just so it can fill it and hash it.
>>> I change it to hash as it goes.
>>
>> How much data is this supposed to hash on average? If it's a large
>> amount then perhaps using the existing crypto API would be a better
>> option than adding this.
>>
>
> This is a good point actually: you didn't explain *why* BPF shouldn't
> depend on the crypto API.

According to Daniel, the networking folks want to let embedded systems
include BPF without requiring the crypto core.

At some point, I'd also like to use modern hash functions for module
verification.  If doing so would require the crypto core to be
available when modules are loaded, then the crypto core couldn't be
modular.  (Although it occurs to me that my patches get that wrong --
if this change happens, I need to split the code so that the library
functions can be built in even if CRYPTO=m.)

Daniel, would you be okay with BPF selecting CRYPTO and CRYPTO_HASH?

Also, as a bikeshed thought: I could call the functions
sha256_init_direct(), etc.  Then there wouldn't be namespace
collisions and the fact that they bypass accelerated drivers would be
more obvious.

--Andy
