From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 07:56:44 -0800
Message-ID: <1482335804.8944.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161221032829.3031.qmail@ns.sciencehorizons.net>
         <1482298164.8944.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAHmME9oCfCwAq1qP09uAN6vvakh4wXDMHunsL9D7W_LDeN_OQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: George Spelvin <linux@sciencehorizons.net>,
        Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        kernel-hardening@lists.openwall.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9oCfCwAq1qP09uAN6vvakh4wXDMHunsL9D7W_LDeN_OQQ@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-12-21 at 15:42 +0100, Jason A. Donenfeld wrote:
> Hi Eric,
> 
> I computed performance numbers for both 32-bit and 64-bit using the
> actual functions in which talking about replacing MD5 with SipHash.
> The basic harness is here [1] if you're curious. SipHash was a pretty
> clear winner for both cases.
> 
> x86_64:
> [    1.714302] secure_tcpv6_sequence_number_md5# cycles: 102373398
> [    1.747685] secure_tcp_sequence_number_md5# cycles: 92042258
> [    1.773522] secure_tcpv6_sequence_number_siphash# cycles: 70786533
> [    1.798701] secure_tcp_sequence_number_siphash# cycles: 68941043
> 
> x86:
> [    1.635749] secure_tcpv6_sequence_number_md5# cycles: 106016335
> [    1.670259] secure_tcp_sequence_number_md5# cycles: 95670512
> [    1.708387] secure_tcpv6_sequence_number_siphash# cycles: 105988635
> [    1.740264] secure_tcp_sequence_number_siphash# cycles: 88225395
> 
> >>> 102373398 > 70786533
> True
> >>> 92042258 > 68941043
> True
> >>> 106016335 > 105988635
> True
> >>> 95670512 > 88225395
> True
> 
> While MD5 is probably faster for some kind of large-data
> cycles-per-byte, due to its 64-byte internal state, SipHash -- the
> "Sip" part standing "Short Input PRF" -- is fast for shorter inputs.
> In practice with the functions we're talking about replacing, there's
> no need to hash 64-bytes. So, SipHash comes out faster and more
> secure.
> 
> I also haven't begun to look focusedly at the assembly my SipHash
> implemention is generating, which means there's still window for even
> more performance improvements.
> 
> Jason
> 
> 
> [1] https://git.zx2c4.com/linux-dev/tree/net/core/secure_seq.c?h=siphash-bench#n194

Now I am quite confused.

George said :

> Cycles per byte on 1024 bytes of data:
>                       Pentium Core 2  Ivy
>                       4       Duo     Bridge
> SipHash-2-4           38.9     8.3     5.8
> HalfSipHash-2-4               12.7     4.5     3.2
> MD5                    8.3     5.7     4.7


That really was for 1024 bytes blocks, so pretty much useless for our
discussion ?

Reading your numbers last week, I thought SipHash was faster, but George
numbers are giving the opposite impression.

I do not have a P4 to make tests, so I only can trust you or George.

Thanks.
