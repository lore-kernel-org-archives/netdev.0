From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 15:56:49 +0100
Message-ID: <f6813084-6f46-0b22-e9c3-97b2e266f8f6@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
 <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
 LKML <linux-kernel@vger.kernel.org>,
 Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
 "Daniel J . Bernstein" <djb@cr.yp.to>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Eric Biggers <ebiggers3@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
 "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5581-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
List-Id: netdev.vger.kernel.org

On 15.12.2016 14:56, David Laight wrote:
> From: Hannes Frederic Sowa
>> Sent: 15 December 2016 12:50
>> On 15.12.2016 13:28, David Laight wrote:
>>> From: Hannes Frederic Sowa
>>>> Sent: 15 December 2016 12:23
>>> ...
>>>> Hmm? Even the Intel ABI expects alignment of unsigned long long to be 8
>>>> bytes on 32 bit. Do you question that?
>>>
>>> Yes.
>>>
>>> The linux ABI for x86 (32 bit) only requires 32bit alignment for u64 (etc).
>>
>> Hmm, u64 on 32 bit is unsigned long long and not unsigned long. Thus I
>> am actually not sure if the ABI would say anything about that (sorry
>> also for my wrong statement above).
>>
>> Alignment requirement of unsigned long long on gcc with -m32 actually
>> seem to be 8.
> 
> It depends on the architecture.
> For x86 it is definitely 4.

May I ask for a reference? I couldn't see unsigned long long being
mentioned in the ia32 abi spec that I found. I agree that those accesses
might be synthetically assembled by gcc and for me the alignment of 4
would have seemed natural. But my gcc at least in 32 bit mode disagrees
with that.

> It might be 8 for sparc, ppc and/or alpha.

This is something to find out...

Right now ipv6 addresses have an alignment of 4. So we couldn't even
naturally pass them to siphash but would need to copy them around, which
I feel like a source of bugs.

Bye,
Hannes
