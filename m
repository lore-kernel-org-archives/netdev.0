From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: rxrpc: Replace time_t type with time64_t type
Date: Wed, 9 Aug 2017 12:00:06 +0200
Message-ID: <CAK8P3a3L11rXAV8-hE1fNtAZyMBNnQneRm5g7F8VDmk7HjQV4A@mail.gmail.com>
References: <cover.1502246501.git.baolin.wang@linaro.org> <8ac57c96bf5a0695ecc67fd230440b0b9d15740f.1502246502.git.baolin.wang@linaro.org>
 <CAK8P3a2WU5uYddGrkWhyfNB4qTEDYne_pyCVG6n5b1w+vb1-OQ@mail.gmail.com> <6767.1502271233@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Baolin Wang <baolin.wang@linaro.org>,
        David Miller <davem@davemloft.net>, james.l.morris@oracle.com,
        "Serge E. Hallyn" <serge@hallyn.com>, marc.dionne@auristor.com,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Mark Brown <broonie@kernel.org>, keyrings@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6767.1502271233@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 9, 2017 at 11:33 AM, David Howells <dhowells@redhat.com> wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
>
>> > @@ -533,8 +536,9 @@ static int rxrpc_preparse_xdr_rxk5(struct key_preparsed_payload *prep,
>> >              pptoken = &(*pptoken)->next)
>> >                 continue;
>> >         *pptoken = token;
>> > -       if (token->kad->expiry < prep->expiry)
>> > -               prep->expiry = token->kad->expiry;
>> ...
>>
>> I'm still slightly puzzled by what this function does: it does have four
>> timestamps (authtime, starttime, endtime, renew_till) that are all
>> transferred as 64-bit values and won't expire, but then it also uses the
>> 32-bit expiry field in rxrpc_key_token->kad->expiry instead of the 64-bit
>> rxrpc_key_token->k5 fields.
>
> Good catch.  This is a cut'n'paste error.  It should be using
> token->k5->expiry here not token->kad->expiry.

Do you know which format is used in practice? Are both kad and k5 common
among rxrpc users?

      Arnd
