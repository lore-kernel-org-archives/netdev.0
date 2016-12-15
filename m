From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 16:53:12 +0100
Message-ID: <924ef794-eae0-2a6b-508b-069718339edc@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
 <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
 <f6813084-6f46-0b22-e9c3-97b2e266f8f6@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240529@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0240529@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.12.2016 16:41, David Laight wrote:
> Try (retyped):
> 
> echo 'struct { long a; long long b; } s; int bar { return sizeof s; }' >foo.c
> gcc [-m32] -O2 -S foo.c; cat foo.s
> 
> And look at what is generated.

I used __alignof__(unsigned long long) with -m32.

>> Right now ipv6 addresses have an alignment of 4. So we couldn't even
>> naturally pass them to siphash but would need to copy them around, which
>> I feel like a source of bugs.
> 
> That is more of a problem on systems that don't support misaligned accesses.
> Reading the 64bit values with two explicit 32bit reads would work.
> I think you can get gcc to do that by adding an aligned(4) attribute to the
> structure member.

Yes, and that is actually my fear, because we support those
architectures. I can't comment on that as I don't understand enough of this.

If someone finds a way to cause misaligned reads on a small box this
seems (maybe depending on sysctls they get fixed up or panic) to be a
much bigger issue than having a hash DoS.

Thanks,
Hannes
