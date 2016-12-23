From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random:
 use SipHash in place of MD5)
Date: Fri, 23 Dec 2016 12:59:59 +0100
Message-ID: <585D11BF.60903@iogearbox.net>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>         <1482425969.2673.5.camel@stressinduktion.org>         <585CF6A3.1050107@iogearbox.net> <1482490762.3353.2.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Theodore Ts'o <tytso@mit.edu>, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Eric Dumazet <edumazet@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482490762.3353.2.camel@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2016 11:59 AM, Hannes Frederic Sowa wrote:
> On Fri, 2016-12-23 at 11:04 +0100, Daniel Borkmann wrote:
>> On 12/22/2016 05:59 PM, Hannes Frederic Sowa wrote:
>>> On Thu, 2016-12-22 at 08:07 -0800, Andy Lutomirski wrote:
[...]
>>> The hashing is not a proper sha1 neither, unfortunately. I think that
>>> is why it will have a custom implementation in iproute2?
>>
>> Still trying to catch up on this admittedly bit confusing thread. I
>> did run automated tests over couple of days comparing the data I got
>> from fdinfo with the one from af_alg and found no mismatch on the test
>> cases varying from min to max possible program sizes. In the process
>> of testing, as you might have seen on netdev, I found couple of other
>> bugs in bpf code along the way and fixed them up as well. So my question,
>> do you or Andy or anyone participating in claiming this have any
>> concrete data or test cases that suggests something different? If yes,
>> I'm very curious to hear about it and willing fix it up, of course.
>> When I'm back from pto I'll prep and cook up my test suite to be
>> included into the selftests/bpf/, should have done this initially,
>> sorry about that. I'll also post something to expose the alg, that
>> sounds fine to me.
>
> Looking into your code closer, I noticed that you indeed seem to do the
> finalization of sha-1 by hand by aligning and padding the buffer
> accordingly and also patching in the necessary payload length.
>
> Apologies for my side for claiming that this is not correct sha1
> output, I was only looking at sha_transform and its implementation and
> couldn't see the padding and finalization round with embedding the data
> length in there and hadn't thought of it being done manually.
>
> Anyway, is it difficult to get the sha finalization into some common
> code library? It is not very bpf specific and crypto code reviewers
> won't find it there at all.

Yes, sure, I'll rework it that way (early next year when I'm back if
that's fine with you).

Thanks,
Daniel
