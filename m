From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 4.10 3/6] bpf: Use SHA256 instead of SHA1 for bpf
 digests
Date: Sat, 24 Dec 2016 20:59:53 +0100
Message-ID: <585ED3B9.6020407@iogearbox.net>
References: <cover.1482545792.git.luto@kernel.org> <bbfd69226fd74391045bafc695bba9a46cacca85.1482545792.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@kernel.org>, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bbfd69226fd74391045bafc695bba9a46cacca85.1482545792.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/24/2016 03:22 AM, Andy Lutomirski wrote:
> BPF digests are intended to be used to avoid reloading programs that
> are already loaded.  For use cases (CRIU?) where untrusted programs
> are involved, intentional hash collisions could cause the wrong BPF
> program to execute.  Additionally, if BPF digests are ever used
> in-kernel to skip verification, a hash collision could give privilege
> escalation directly.

Just for the record, digests will never ever be used to skip the
verification step, so I don't know why this idea even comes up
here (?) or is part of the changelog? As this will never be done
anyway, rather drop that part so we can avoid confusion on this?

Wrt untrusted programs, I don't see much of a use on this facility
in general for them. Something like a tail call map would quite
likely only be private to the application. And again, I really doubt
we'll have something like user namespace support in the foreseeable
future. Anyway, that said, I don't really have a big issue if you
want to switch to sha256, though.

> SHA1 is no longer considered adequately collision-resistant (see, for
> example, all the major browsers dropping support for SHA1
> certificates).  Use SHA256 instead.
>
> I moved the digest field to keep all of the bpf program metadata in
> the same cache line.
>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
