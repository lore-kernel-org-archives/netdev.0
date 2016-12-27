From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC PATCH 4.10 1/6] crypto/sha256: Refactor the API so it can be
 used without shash
Date: Tue, 27 Dec 2016 11:00:17 -0800
Message-ID: <CALCETrXy6QXLKTih9e=ceMZes=SjHEMGg+vW1sXdiRg5Qaxt7g@mail.gmail.com>
References: <cover.1482545792.git.luto@kernel.org> <942b91f25a63b22ec4946378a1fffe78d655cf18.1482545792.git.luto@kernel.org>
 <CAKv+Gu-UCqwchgbhg8VN4s=Yxk=PkjXG46NZo=8P4wAQtJ2TXw@mail.gmail.com>
 <CALCETrVbT_1=cdU1+a-+KbhoFqeT3XvbHjY0s_U7C5JVgiPx_Q@mail.gmail.com>
 <20161226075757.GA8916@gondor.apana.org.au> <CAKv+Gu-NMNCEs61f4k7JSf9iSJ1A_Gy1r=kZRGqtbDsEDz7--Q@mail.gmail.com>
 <CALCETrXFTQ2AXgbQzPnRcDRHK81=FS1R0zqfoTqGjUsqZy2PvQ@mail.gmail.com>
 <20161227095853.GA10588@gondor.apana.org.au> <586277AE.80401@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Andy Lutomirski <luto@kernel.org>,
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
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:34367 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756138AbcL0TAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 14:00:39 -0500
Received: by mail-ua0-f171.google.com with SMTP id 34so150777389uac.1
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2016 11:00:38 -0800 (PST)
In-Reply-To: <586277AE.80401@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 27, 2016 at 6:16 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 12/27/2016 10:58 AM, Herbert Xu wrote:
>>
>> On Mon, Dec 26, 2016 at 10:08:48AM -0800, Andy Lutomirski wrote:
>>>
>>>
>>> According to Daniel, the networking folks want to let embedded systems
>>> include BPF without requiring the crypto core.
>>
>>
>> Last I checked the IPv4 stack depended on the crypto API so this
>> sounds bogus.
>
>
> I think there's a bit of a mixup here with what I said. To clarify,
> requirement back then from tracing folks was that bpf engine and
> therefore bpf syscall can be build w/o networking enabled for small
> devices, so dependencies preferably need to be kept on a absolute
> minimum, same counts for either making it suddenly a depend on
> CRYPTO or a select CRYPTO for just those few lines that can be
> pulled in from lib/ code instead.

Somehow I had that in my head as "networking" not "tracing", probably
because of the TCA stuff.  Whoops.

Anyway, I'm rewriting the crypto part of the patch completely based on
Ard's feedback.
