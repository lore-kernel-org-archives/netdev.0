From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 20:22:04 +0100
Message-ID: <0e708ba2-6a4e-013e-597a-62ab32cc240b@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com>
 <20161214.125612.1361254098267633173.davem@davemloft.net>
 <CAHmME9pz4XudfeqhKBwFNDmp7AYuNwbnevMqB3e6ScPDnUnq9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        Andi Kleen <ak@linux.intel.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pz4XudfeqhKBwFNDmp7AYuNwbnevMqB3e6ScPDnUnq9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14.12.2016 19:06, Jason A. Donenfeld wrote:
> Hi David,
> 
> On Wed, Dec 14, 2016 at 6:56 PM, David Miller <davem@davemloft.net> wrote:
>> Just marking the structure __packed, whether necessary or not, makes
>> the compiler assume that the members are not aligned and causes
>> byte-by-byte accesses to be performed for words.
>> Never, _ever_, use __packed unless absolutely necessary, it pessimizes
>> the code on cpus that require proper alignment of types.
> 
> Oh, jimminy cricket, I did not realize that it made assignments
> byte-by-byte *always*. So what options am I left with? What
> immediately comes to mind are:
> 
> 1)
> 
> struct {
>     u64 a;
>     u32 b;
>     u32 c;
>     u16 d;
>     u8 end[];

I don't think this helps. Did you test it? I don't see reason why
padding could be left out between `d' and `end' because of the flexible
array member?

Bye,
Hannes
