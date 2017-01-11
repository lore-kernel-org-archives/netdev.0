From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 8/8] crypto/testmgr: Allocate only the required output
 size for hash tests
Date: Wed, 11 Jan 2017 10:10:27 -0800
Message-ID: <CALCETrX_8_sbGgc4N8opSnXimnZNp5HbTvdonnHoFic8b_Zp-A@mail.gmail.com>
References: <cover.1484090585.git.luto@kernel.org> <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6DB025EE7B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>,
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
        "David S. Miller" <davem@davemloft.net>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:35438 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937665AbdAKSK5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 13:10:57 -0500
Received: by mail-ua0-f178.google.com with SMTP id y9so186352311uae.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 10:10:48 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB025EE7B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 7:13 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Andy Lutomirski
>> Sent: 10 January 2017 23:25
>> There are some hashes (e.g. sha224) that have some internal trickery
>> to make sure that only the correct number of output bytes are
>> generated.  If something goes wrong, they could potentially overrun
>> the output buffer.
>>
>> Make the test more robust by allocating only enough space for the
>> correct output size so that memory debugging will catch the error if
>> the output is overrun.
>
> Might be better to test this by allocating an overlong buffer
> and then explicitly checking that the output hasn't overrun
> the allowed space.
>
> If nothing else the error message will be clearer.

I thought about that, but then I'd have to figure out what poison
value to use.  Both KASAN and the usual slab debugging are quite good
at this kind of checking, and KASAN will even point you to the
problematic code directly.

--Andy


-- 
Andy Lutomirski
AMA Capital Management, LLC
