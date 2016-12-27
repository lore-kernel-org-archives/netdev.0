From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC PATCH 4.10 3/6] bpf: Use SHA256 instead of SHA1 for bpf digests
Date: Mon, 26 Dec 2016 18:08:18 -0800
Message-ID: <CALCETrWsR6Lsy_gY1uBMh2UbYm+Z7v5mV_96bSeb6Ru8hyhA2A@mail.gmail.com>
References: <cover.1482545792.git.luto@kernel.org> <bbfd69226fd74391045bafc695bba9a46cacca85.1482545792.git.luto@kernel.org>
 <585ED3B9.6020407@iogearbox.net> <20161227013644.GA96815@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Andy Lutomirski <luto@kernel.org>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161227013644.GA96815@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 26, 2016 at 5:36 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sat, Dec 24, 2016 at 08:59:53PM +0100, Daniel Borkmann wrote:
>> On 12/24/2016 03:22 AM, Andy Lutomirski wrote:
>> >BPF digests are intended to be used to avoid reloading programs that
>> >are already loaded.  For use cases (CRIU?) where untrusted programs
>> >are involved, intentional hash collisions could cause the wrong BPF
>> >program to execute.  Additionally, if BPF digests are ever used
>> >in-kernel to skip verification, a hash collision could give privilege
>> >escalation directly.
>>
>> Just for the record, digests will never ever be used to skip the
>> verification step, so I don't know why this idea even comes up
>> here (?) or is part of the changelog? As this will never be done
>> anyway, rather drop that part so we can avoid confusion on this?
>
> +1 to what Daniel said above.
>
> For the others let me explain what this patch set is actually
> trying to accomplish.

The patch:

a) cleans up the code and

b) uses a cryptographic hash that is actually believed to satisfy the
definition of a cryptographic hash.

There's no excuse for not doing b.

> and I have an obvious NACK for bpf related patches 3,4,5,6.

Did you *read* the ones that were pure cleanups?

>
> sha1 is 20 bytes which is already a bit long to print and copy paste by humans.
> whereas 4 byte jhash is a bit too short, since collisions are not that rare
> and may lead to incorrect assumptions from the users that develop the programs.
> I would prefer something in 6-10 byte range that prevents collisions most of
> the time and short to print as hex, but I don't know of anything like this
> in the existing kernel and inventing bpf specific hash is not great.
> Another requirement for debugging (and prog_digest) that user space
> should be able to produce the same hash without asking kernel, so
> sha1 fits that as well, since it's well known and easy to put into library.

Then truncate them in user space.
