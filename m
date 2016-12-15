From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 13:23:18 +0100
Message-ID: <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
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
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.12.2016 12:04, David Laight wrote:
> From: Hannes Frederic Sowa
>> Sent: 14 December 2016 22:03
>> On 14.12.2016 13:46, Jason A. Donenfeld wrote:
>>> Hi David,
>>>
>>> On Wed, Dec 14, 2016 at 10:56 AM, David Laight <David.Laight@aculab.com> wrote:
>>>> ...
>>>>> +u64 siphash24(const u8 *data, size_t len, const u8 key[SIPHASH24_KEY_LEN])
>>>> ...
>>>>> +     u64 k0 = get_unaligned_le64(key);
>>>>> +     u64 k1 = get_unaligned_le64(key + sizeof(u64));
>>>> ...
>>>>> +             m = get_unaligned_le64(data);
>>>>
>>>> All these unaligned accesses are going to get expensive on architectures
>>>> like sparc64.
>>>
>>> Yes, the unaligned accesses aren't pretty. Since in pretty much all
>>> use cases thus far, the data can easily be made aligned, perhaps it
>>> makes sense to create siphash24() and siphash24_unaligned(). Any
>>> thoughts on doing something like that?
>>
>> I fear that the alignment requirement will be a source of bugs on 32 bit
>> machines, where you cannot even simply take a well aligned struct on a
>> stack and put it into the normal siphash(aligned) function without
>> adding alignment annotations everywhere. Even blocks returned from
>> kmalloc on 32 bit are not aligned to 64 bit.
> 
> Are you doing anything that will require 64bit alignment on 32bit systems?
> It is unlikely that the kernel can use any simd registers that have wider
> alignment requirements.
> 
> You also really don't want to request on-stack items have large alignments.
> While gcc can generate code to do it, it isn't pretty.

Hmm? Even the Intel ABI expects alignment of unsigned long long to be 8
bytes on 32 bit. Do you question that?
